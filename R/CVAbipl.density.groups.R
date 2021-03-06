CVAbipl.density.groups <-
function (X, G = NULL, X.new = NULL, e.vects = 1:ncol(X), adequacies.print = F, 
    alpha = 0.5, ax = 1:ncol(X), ax.pred.above = NULL, ax.col = list(ax.col = rep("black", 
        ncol(X)), tickmarker.col = rep("black", ncol(X)), marker.col = rep("black", 
        ncol(X))), ax.name.col = rep("black", ncol(X)), ax.name.size = 0.65, 
    ax.type = c("predictive", "interpolative"), bandwidth = NULL, 
    basket.n = 36, basket.beta = 0.4, between = c(1, -1, 0, 1), 
    between.columns = -1, char.legend.size = c(1.2, 0.7), c.hull.n = 10, 
    colours = c(4:12, 3:1), colour.scheme = NULL, colours.density = matrix(rep(c("white", 
        "red"), ncol(G)), byrow = T, nrow = ncol(G)), columns = 1, 
    cuts.density = 50, dens.ax.cex = 0.6, dens.ax.tcl = -0.2, 
    dens.mgp = c(0, -0.25, 0), draw.densitycontours = F, exp.factor = 1.2, 
    label = T, label.size = 0.6, large.scale = F, layout.heights = c(100, 
        10), legend.type = c(means = TRUE, samples = FALSE, bags = FALSE), 
    line.length = c(1, 1), line.size = 2.5, line.type = 1:ncol(G), 
    line.width = 1, markers = T, marker.size = 0.5, max.num = 2500, 
    means.plot = T, n.int = rep(5, ncol(X)), offset = rep(0.5, 
        4), offset.m = rep(0.001, ncol(X)), parlegendmar = c(0, 
        6, 2.5, 6), parlegendmar.dens = c(2, 5, 0, 5), parplotmar = rep(3, 
        4), pch.means = 0:10, pch.means.size = 1, pch.samples = 0:10, 
    pch.samples.size = 1, pos = c("Orthog", "Hor", "Paral"), 
    predictivity.print = F, quality.print = F, smooth.n = 100, 
    specify.bags = dimnames(G)[[2]], specify.classes = dimnames(G)[[2]], 
    specify.density.classes = dimnames(G)[[2]], specify.beta.baskets = dimnames(G)[[2]], 
    Title = NULL, Tukey.median = T) 
{
    if (!is.null(colour.scheme)) {
        my.colours <- colorRampPalette(colour.scheme)
        colours <- my.colours(colours)
    }
    ax.type <- ax.type[1]
    pos <- pos[1]
    B.opt <- NULL
    old.par <- par(no.readonly = FALSE)
    if (adequacies.print & predictivity.print) 
        stop("adequacies.print and predictivity.print cannot both be set to TRUE")
    if (is.null(G)) {
        cat("Use function PCAbipl.boek for a PCA biplot or provide G for a CVA biplot\n")
        return(invisible())
    }
    if (!is.null(G)) 
        if ((length(specify.bags) > ncol(G)) | (length(specify.classes) > 
            ncol(G)) | (length(specify.density.classes) > ncol(G))) 
            stop("Number of specified bags or classes or specified density classes must not be larger than \n      the number of different classes")
    J <- ncol(G)
    if (ncol(G) == 2) 
        warning("Two class CVA biplot reduces to a line; second axis constructed according to Le Roux & Gardner-Lubbe 2008, \n")
    layout(matrix(1:2, ncol = 1), heights = layout.heights)
    par(pty = "s", mar = parplotmar, cex = 1)
    on.exit(par(old.par))
    if (is.null(dimnames(G))) 
        dimnames(G) <- list(NULL, paste("class", 1:J, sep = ""))
    if (length(dimnames(G)[[2]]) == 0) 
        dimnames(G)[[2]] <- paste("class", 1:J, sep = "")
    n.groups <- apply(G, 2, sum)
    if (is.numeric(specify.bags)) 
        stop("Class names must be supplied, not numeric values")
    if (!is.null(specify.bags)) {
        if (!is.numeric(specify.bags)) {
            test <- match(specify.bags, unique(as.character(dimnames(G)[[2]])), 
                nomatch = 0)
            if (sum(test != 0) < length(specify.bags)) 
                stop(" One or more of specified classes non-existent.  Check spelling")
        }
    }
    if (!is.null(specify.bags)) {
        select.numeric.bags <- rep(0, length(specify.bags))
        for (k in 1:length(specify.bags)) select.numeric.bags[k] <- (1:length(dimnames(G)[[2]]))[dimnames(G)[[2]] == 
            specify.bags[k]]
    }
    else {
        if (is.null(specify.bags)) 
            select.numeric.bags <- NULL
    }
    if (!is.null(specify.beta.baskets)) {
        select.numeric.beta.baskets <- rep(0, length(specify.beta.baskets))
        for (k in 1:length(specify.beta.baskets)) select.numeric.beta.baskets[k] <- (1:length(dimnames(G)[[2]]))[dimnames(G)[[2]] == 
            specify.beta.baskets[k]]
    }
    else {
        if (is.null(specify.beta.baskets)) 
            select.numeric.beta.baskets <- NULL
    }
    if (is.numeric(specify.classes)) 
        stop("Class names must be supplied, not numeric values")
    if (!is.null(specify.classes)) {
        if (!is.numeric(specify.classes)) {
            test <- match(specify.classes, unique(as.character(dimnames(G)[[2]])), 
                nomatch = 0)
            if (sum(test != 0) < length(specify.classes)) 
                stop(" One or more of specified classes non-existent.  Check spelling")
        }
    }
    if (!is.null(specify.classes)) {
        select.numeric.classes <- rep(0, length(specify.classes))
        for (k in 1:length(specify.classes)) select.numeric.classes[k] <- (1:length(dimnames(G)[[2]]))[dimnames(G)[[2]] == 
            specify.classes[k]]
    }
    else {
        if (is.null(specify.classes)) 
            select.numeric.classes <- NULL
    }
    if (is.numeric(specify.density.classes)) 
        stop("Class names must be supplied, not numeric values")
    if (!is.null(specify.density.classes)) {
        if (!is.numeric(specify.density.classes)) {
            test <- match(specify.density.classes, unique(as.character(dimnames(G)[[2]])), 
                nomatch = 0)
            if (sum(test != 0) < length(specify.density.classes)) 
                stop(" One or more of specified density classes non-existent.  Check spelling")
        }
    }
    if (!is.null(specify.density.classes)) {
        select.numeric.density.classes <- rep(0, length(specify.density.classes))
        for (k in 1:length(specify.density.classes)) select.numeric.density.classes[k] <- (1:length(dimnames(G)[[2]]))[dimnames(G)[[2]] == 
            specify.density.classes[k]]
    }
    else {
        if (is.null(specify.density.classes)) 
            select.numeric.density.classes <- NULL
    }
    dimnames(G)[[2]] <- paste(dimnames(G)[[2]], "; n = ", n.groups, 
        sep = "")
    means <- apply(X, 2, mean)
    unscaled.X <- X
    X <- scale(X, scale = F)
    if (nrow(X) != nrow(G)) {
        stop("Rows of X and G unequal!!")
    }
    class.vec <- apply(t(apply(G, 1, function(x) x == max(x))), 
        1, function(s, G) dimnames(G)[[2]][s], G = G)
    n <- nrow(X)
    p <- ncol(X)
    J <- ncol(G)
    K <- min(p, J - 1)
    if (J > length(pch.means)) 
        stop(paste("Increase size of pch.means argument"))
    if (J > length(pch.samples)) 
        stop(paste("Increase size of pch.samples argument"))
    if (J > length(colours)) 
        stop(paste("Increase size of colours argument"))
    if (is.null(dimnames(X))) 
        dimnames(X) <- list(paste("s", 1:n, sep = ""), paste("V", 
            1:p, sep = ""))
    if (length(dimnames(X)[[1]]) == 0) 
        dimnames(X)[[1]] <- paste("s", 1:n, sep = "")
    if (length(dimnames(X)[[2]]) == 0) 
        dimnames(X)[[2]] <- paste("V", 1:p, sep = "")
    if (length(e.vects) < 2) 
        stop("No, it is a 2-dimensional biplot")
    S11 <- t(G) %*% G/n
    S12 <- t(G) %*% X/n
    S22 <- t(X) %*% X/n
    S11.sqrt <- svd(S11)$u %*% diag(svd(S11)$d^0.5) %*% t(svd(S11)$u)
    S22.sqrt <- svd(S22)$u %*% diag(svd(S22)$d^0.5) %*% t(svd(S22)$u)
    S.B <- t(S12) %*% solve(S11) %*% S12
    S.W <- S22 - S.B
    W.sqrt <- svd(S.W)$u %*% diag(svd(S.W)$d^0.5) %*% t(svd(S.W)$u)
    B <- solve(W.sqrt) %*% svd(solve(W.sqrt) %*% S.B %*% solve(W.sqrt))$u
    svd1 <- svd(solve(S11) %*% S12 %*% solve(S22) %*% t(S12))
    svd2 <- svd(solve(S11.sqrt) %*% S12 %*% solve(S22) %*% t(S12) %*% 
        solve(S11.sqrt))
    means.mat <- solve(S11 * n) %*% t(G) %*% X
    CVA.mean <- means.mat %*% B[, e.vects[1:2]]
    Z.means.mat <- data.frame(CVA.mean, pch.means = pch.means[1:J], 
        colr = as.character(colours[1:J]), line.type[1:J], pch.means.size = pch.means.size, 
        stringsAsFactors = FALSE)
    classnames <- dimnames(Z.means.mat)[[1]]
    if (J - 1 < p) {
        B.sup2 <- solve(B)[-(1:(J - 1)), , drop = F]
        fmat.opt <- svd(B.sup2 %*% t(B.sup2))$v
        B2.opt <- B[, -(1:(J - 1))] %*% fmat.opt
        B.opt <- cbind(B[, 1:(J - 1)], B2.opt)
        Z.opt <- X %*% B.opt
    }
    if (J - 1 < p) 
        Z <- X %*% B.opt[, e.vects[1:2]]
    else Z <- X %*% B[, e.vects[1:2]]
    Z <- data.frame(Z, pch.sampl = pch.samples[1], colr = as.character(colours[1]), 
        linetype = line.type[1], stringsAsFactors = FALSE)
    if (J > 0) 
        for (j in 1:J) {
            Z[G[, j] == 1, 4] <- colours[j]
            Z[G[, j] == 1, 3] <- pch.samples[j]
            Z[G[, j] == 1, 5] <- line.type[j]
        }
    if (is.null(specify.bags)) {
        line.type <- NULL
        Z <- Z[, 1:4]
    }
    if (J - 1 < p) {
        Br <- B.opt[, e.vects[1:2]]
        Brr <- solve(B.opt)[e.vects[1:2], ]
    }
    else {
        Br <- B[, e.vects[1:2]]
        Brr <- solve(B)[e.vects[1:2], ]
    }
    if (ax.type == "predictive") 
        axes.rows <- solve(diag(diag(t(Brr) %*% Brr))) %*% t(Brr)
    else {
        if (ax.type == "interpolative") 
            axes.rows <- Br
        else stop("ax.type is either 'interpolative' or 'predictive' (the default). \n")
    }
    z.axes <- lapply(1:p, function(j, unscaled.X, means, axes.rows, 
        n.int) {
        number.points <- 100
        std.markers <- pretty(unscaled.X[, j], n = n.int[j])
        std.range <- c(min(std.markers), max(std.markers))
        std.markers.min <- std.markers - (std.range[2] - std.range[1])
        std.markers.max <- std.markers + (std.range[2] - std.range[1])
        std.markers <- c(std.markers, std.markers.min, std.markers.max)
        interval <- std.markers - means[j]
        axis.vals <- seq(from = min(interval), to = max(interval), 
            length = number.points)
        axis.vals <- sort(unique(c(axis.vals, interval)))
        number.points <- length(axis.vals)
        axis.points <- matrix(0, nrow = number.points, ncol = 4)
        axis.points[, 1] <- axis.vals * axes.rows[j, 1]
        axis.points[, 2] <- axis.vals * axes.rows[j, 2]
        axis.points[, 3] <- axis.vals + means[j]
        axis.points[, 4] <- 0
        for (i in 1:number.points) if (any(zapsmall(axis.points[i, 
            3] - std.markers) == 0)) 
            axis.points[i, 4] <- 1
        return(axis.points)
    }, unscaled.X = unscaled.X, means = means, axes.rows = axes.rows, 
        n.int = n.int)
    lambda.vec <- svd(solve(W.sqrt) %*% S.B %*% solve(W.sqrt))$d
    lambda.vec <- zapsmall(lambda.vec)
    CVA.quality <- sum(lambda.vec[e.vects[1:2]])/sum(lambda.vec)
    adequacy.p <- diag(Br %*% t(Br))/diag(B %*% t(B))
    names(adequacy.p) <- dimnames(X)[[2]]
    display.quality <- paste("CVA.quality =", round(CVA.quality * 
        100, digits = 2), "%")
    if (adequacies.print) 
        dimnames(X)[[2]] <- paste(dimnames(X)[[2]], " (", round(adequacy.p, 
            digits = 3), ")", sep = "")
    uit <- drawbipl.bagalpha.density.groups(Z, z.axes, z.axes.names = dimnames(X)[[2]], 
        p = p, ax = ax, ax.col = ax.col, ax.name.size = ax.name.size, 
        alpha = alpha, basket.beta = basket.beta, basket.n = basket.n, 
        pch.means = pch.means, pch.means.size = pch.means.size, 
        pch.samples.size = pch.samples.size, specify.bags = select.numeric.bags, 
        label = label, markers = markers, Title = Title, means.plot = means.plot, 
        large.scale = large.scale, specify.classes = select.numeric.classes, 
        specify.density.classes = select.numeric.density.classes, 
        specify.beta.baskets = select.numeric.beta.baskets, Tukey.median = Tukey.median, 
        c.hull.n = c.hull.n, Z.means.mat = Z.means.mat, offset = offset, 
        offset.m = offset.m, pos = pos, pos.m = pos.m, strepie = line.length, 
        max.num = max.num, marker.size = marker.size, label.size = label.size, 
        exp.factor = exp.factor, line.width = line.width, class.vec = class.vec, 
        smooth.n = smooth.n, cuts.density = cuts.density, colours.density = colours.density, 
        draw.densitycontours = draw.densitycontours, parlegendmar.dens = parlegendmar.dens, 
        dens.ax.cex = dens.ax.cex, dens.ax.tcl = dens.ax.tcl, 
        dens.mgp = dens.mgp, bandwidth = bandwidth, layout.heights = layout.heights)
    if (!(is.null(X.new))) {
        pch.new <- paste("N", 1:nrow(X.new), sep = "")
        Z.new <- scale(X.new, means, scale = F) %*% Br
        text(Z.new, labels = pch.new, cex = pch.samples.size, 
            col = "black")
    }
    if (!is.null(uit)) 
        dimnames(G)[[2]][select.numeric.bags] <- uit
    if (any(legend.type)) {
        dev.new()
        blegend.colchar(quality.print = quality.print, QualityOfDisplay = display.quality, 
            classes = dimnames(G)[[2]], pch.means = as.vector(pch.means[1:J]), 
            pch.samples = as.vector(pch.samples[1:J]), colours = as.vector(colours[1:J]), 
            line.type = as.vector(line.type[1:J]), line.width = line.width, 
            pch.samples.size = char.legend.size, legend.type = legend.type, 
            between = between, columns = columns, parlegendmar = parlegendmar, 
            line.size = line.size, between.columns = between.columns)
    }
    normalising.constant <- sum((scale(unscaled.X, scale = F, 
        center = T))^2)
    normalised.reconstruction.error.B <- round(CVA.predictions.mat(X = scale(unscaled.X, 
        scale = F, center = T), B = B)$reconstr.error/normalising.constant, 
        digits = 4)
    if (J - 1 < p) {
        normalised.reconstruction.error.B.opt <- round(CVA.predictions.mat(X = scale(unscaled.X, 
            scale = F, center = T), B = B.opt)$reconstr.error/normalising.constant, 
            digits = 4)
    }
    else normalised.reconstruction.error.B.opt <- NULL
    list(Br = Br, CVA.quality = CVA.quality, normalised.reconstruction.error.B = normalised.reconstruction.error.B, 
        normalised.reconstruction.error.B.opt = normalised.reconstruction.error.B.opt, 
        adequacy = adequacy.p)
}
