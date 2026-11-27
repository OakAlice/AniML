# Preprocessing -----------------------------------------------------------
# Rotate all individuals to the same orientation and then filter outliers

preprocessing <- function(data, sample_rate, scale = FALSE, filter = FALSE, rotate = FALSE, rotation_ref_data = NULL){
  
  if (scale){
    data <- standardise_scale(data)
  }
  
  # rotate all individuals to the same orientation
  if (rotate){
    data <- standardise_rotation(data, 
                                 rotation_ref_data)
  }
  
  # smooth
  if (filter){
    data <- filter_noise(data, sample_rate)
  }
  
  data <- data[, sequence := NULL]
  
  # return
  return(data)
}




standardise_rotation <- function(data,
                                 rotation_ref_data,
                                 available_axes = c("X", "Y", "Z"),
                                 win = 100L,              # 2 s at 50 Hz
                                 max_n = 5e5) {
  
  other_data <- data.table::copy(data.table::as.data.table(data))
  reference  <- data.table::as.data.table(rotation_ref_data)
  
  # gravity-based orientation frame: mean direction + main axis of posture variation
  frame <- function(d) {
    G <- as.matrix(d[, lapply(.SD, data.table::frollmean, n = win, align = "center"),
                     .SDcols = available_axes])
    G <- G[stats::complete.cases(G), , drop = FALSE]
    if (nrow(G) < 100L) stop("Not enough complete data to estimate orientation")
    M <- G[sample(nrow(G), min(nrow(G), max_n)), , drop = FALSE]
    
    m  <- colMeans(M)
    e1 <- m / sqrt(sum(m^2))
    pc <- stats::prcomp(M, center = TRUE)$rotation[, 1]
    e2 <- pc - sum(pc * e1) * e1
    e2 <- e2 / sqrt(sum(e2^2))
    e3 <- c(e1[2] * e2[3] - e1[3] * e2[2],
            e1[3] * e2[1] - e1[1] * e2[3],
            e1[1] * e2[2] - e1[2] * e2[1])
    list(F = cbind(e1, e2, e3), M = M)
  }
  
  skew <- function(x) mean((x - mean(x))^3) / stats::sd(x)^3
  
  fr <- frame(reference)                                  # reference frame, computed once
  
  ids <- unique(other_data$ID)
  rotations <- vector("list", length(ids))
  names(rotations) <- ids
  
  for (id in ids) {
    rows <- which(other_data$ID == id)
    fd   <- frame(other_data[rows])                       # this individual only
    
    # PC sign is arbitrary: match skewness of the posture axis to the reference
    if (sign(skew(fr$M %*% fr$F[, 2])) != sign(skew(fd$M %*% fd$F[, 2])))
      fd$F[, 2:3] <- -fd$F[, 2:3]                         # keeps det = +1
    
    R <- fd$F %*% t(fr$F)                                 # maps this individual's axes into the reference axes
    rotations[[as.character(id)]] <- R
    message("Rotation for ", id, ":\n", paste(capture.output(print(round(R, 2))), collapse = "\n"))
    
    rot <- function(cols) {
      rotated <- as.matrix(other_data[rows, ..cols]) %*% R
      for (k in seq_along(cols))
        data.table::set(other_data, i = rows, j = cols[k], value = rotated[, k])
    }
    rot(available_axes)
  }
  
  attr(other_data, "rotations") <- rotations
  return(other_data)
}


filter_noise <- function(data, sample_rate, available_axes = c("X", "Y", "Z"),
                         bw_cutoff = 5, bw_order = 4, max_break = 3) {
  
  data <- data.table::copy(data.table::as.data.table(data))
  data <- data[stats::complete.cases(data[, ..available_axes])]   # only drop NAs in the axes
  data.table::setorder(data, Time)
  data <- identify_sequences(data, max_break = max_break)
  data.table::setDT(data)
  
  bf      <- signal::butter(bw_order, bw_cutoff / (sample_rate / 2), type = "low")
  min_len <- 3L * (bw_order + 1L) + 1L # hard minimum for filtfilt
  
  segments <- split(data, by = "sequence")
  
  filtered <- lapply(segments, function(df) {
    if (nrow(df) < min_len) return(NULL) # too short to filter: drop
    for (col in available_axes) {
      data.table::set(df, j = col,
                      value = as.numeric(signal::filtfilt(bf, df[[col]])))
    }
    df
  })
  
  out <- data.table::rbindlist(filtered)
  data.table::setorder(out, Time)
  out[]
}

standardise_rotation <- function(data, axes = c("X", "Y", "Z"), target_sign = -1, plot = TRUE, beh = "Hopping") {
  
  dt <- copy(as.data.table(data))
  cross <- function(a, b) c(a[2]*b[3] - a[3]*b[2],
                            a[3]*b[1] - a[1]*b[3],
                            a[1]*b[2] - a[2]*b[1])
  
  # a) per-individual gravity vector (median is robust to dynamic movement)
  grav_before <- dt[, lapply(.SD, median, na.rm = TRUE), by = ID, .SDcols = axes]
  
  # b) build a proper rotation (det = +1, no reflection) per individual
  #    so the dominant gravity axis becomes Y, with sign = target_sign
  rot_list <- lapply(grav_before$ID, function(id) {
    g  <- unlist(grav_before[ID == id, ..axes])
    a  <- which.max(abs(g))                 # dominant axis
    k  <- target_sign * sign(g[a])          # flip so gravity on new Y has target sign
    ey <- numeric(3); ey[a] <- k
    ex <- numeric(3); ex[setdiff(1:3, a)[1]] <- 1
    ez <- cross(ex, ey)                     # right-handed frame
    R  <- rbind(ex, ey, ez)                 # rows = new axes in old coordinates
    list(R = R, dominant = axes[a])
  })
  names(rot_list) <- grav_before$ID
  
  # keep raw values for plotting
  raw <- copy(dt[, c("ID", "Activity", axes), with = FALSE])
  
  # apply rotation by individual
  for (id in grav_before$ID) {
    idx <- which(dt$ID == id)
    m   <- as.matrix(dt[idx, ..axes]) %*% t(rot_list[[id]]$R)
    set(dt, idx, axes, as.data.table(m))
  }
  
  grav_after <- dt[, lapply(.SD, median, na.rm = TRUE), by = ID, .SDcols = axes]

  if (plot) {
    
    # plot a contiguous walking snippet per individual, before vs after
    n_win <- 2000   # samples per snippet
    set.seed(1)
    
    # row indices (within each ID) of a random contiguous walking run of n_win samples
    pick <- dt[, {
      is_walk <- Activity == beh
      r       <- rle(is_walk)
      ends    <- cumsum(r$lengths)
      starts  <- ends - r$lengths + 1
      ok      <- which(r$values & r$lengths >= n_win)
      if (length(ok) == 0) {
        # fall back to the longest walking run, or nothing if none
        ok <- which(r$values)
        if (length(ok)) ok <- ok[which.max(r$lengths[ok])]
      }
      if (length(ok) == 0) {
        list(row = integer(0), t = integer(0))
      } else {
        j   <- if (length(ok) > 1) sample(ok, 1) else ok
        len <- min(n_win, r$lengths[j])
        rows <- starts[j]:(starts[j] + len - 1)
        list(row = rows, t = seq_len(len))
      }
    }, by = ID]
    
    if (nrow(pick) == 0) {
      message("No samples for this behaviour (define the beh in the function).")
    } else {
      # map within-ID row index back to global row index
      dt[, .rid := seq_len(.N), by = ID]
      raw[, .rid := seq_len(.N), by = ID]
      pick[, key := paste(ID, row)]
      
      sel_after  <- dt[,  key := paste(ID, .rid)][key %in% pick$key]
      sel_before <- raw[, key := paste(ID, .rid)][key %in% pick$key]
      sel_after  <- merge(sel_after[,  c("ID", "key", axes), with = FALSE], pick[, .(key, t)], by = "key")
      sel_before <- merge(sel_before[, c("ID", "key", axes), with = FALSE], pick[, .(key, t)], by = "key")
      
      tb <- melt(sel_before[, State := "Before"], id.vars = c("ID", "t", "State", "key"), variable.name = "Axis")
      ta <- melt(sel_after[,  State := "After"],  id.vars = c("ID", "t", "State", "key"), variable.name = "Axis")
      tt <- rbind(tb, ta)
      tt[, State := factor(State, levels = c("Before", "After"))]
      
      print(
        ggplot(tt, aes(t, value, colour = Axis)) +
          geom_line() +
          facet_grid(ID ~ State) +
          labs(x = "Sample", y = "Acceleration (g)") +
          my_theme()
      )
    }
  }
  
  attr(dt, "rotations") <- lapply(rot_list, `[[`, "R")
  dt[]
}
