# Preprocessing -----------------------------------------------------------
# Rotate all individuals to the same orientation and then filter outliers

preprocessing <- function(data){
  
  # rotate all individuals to the same orientation
  rotated <- standardise_rotation(data)
  
  # smooth
  smoothed <- filter_noise(rotated)
  
  # return
  return(smoothed)
}


standardise_rotation <- function(data, axes = c("X", "Y", "Z"), target_sign = -1, plot = TRUE, beh = "Locomotion") {
  
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
    n_win <- 400   # samples per snippet
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
      message("No 'Walking' samples found; skipping Plot 3.")
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
  
  # sanity check printed to console
  message("Dominant gravity axis per ID (before rotation):")
  print(data.table(ID = names(rot_list), Dominant = sapply(rot_list, `[[`, "dominant")))
  message("Median Y after rotation (should have sign ", target_sign, "):")
  print(grav_after[, .(ID, Y)])
  
  attr(dt, "rotations") <- lapply(rot_list, `[[`, "R")
  dt[]
}