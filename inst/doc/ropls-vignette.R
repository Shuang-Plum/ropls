## ----global_options, include=FALSE-----------------------------------------
knitr::opts_chunk$set(fig.width=6, fig.height=6, fig.path='figures/')

## ----load------------------------------------------------------------------
library(ropls)

## ----sacurine--------------------------------------------------------------
data(sacurine)
names(sacurine)

## ----attach_code, message = FALSE------------------------------------------
attach(sacurine)

## ----strF------------------------------------------------------------------
strF(dataMatrix)
strF(sampleMetadata)
strF(variableMetadata)

## ----pca_code, eval = FALSE------------------------------------------------
#  sacurine.pca <- opls(dataMatrix)

## ----pca_result, echo = FALSE----------------------------------------------
sacurine.pca <- opls(dataMatrix, plotL = FALSE)

## ----pca_figure, echo = FALSE, fig.show = 'hold'---------------------------
layout(matrix(1:4, nrow = 2, byrow = TRUE))
for(typeC in c("overview", "outlier", "x-score", "x-loading"))
plot(sacurine.pca, typeVc = typeC, parDevNewL = FALSE)

## ----pca-col, eval = FALSE-------------------------------------------------
#  genderFc <- sampleMetadata[, "gender"]
#  plot(sacurine.pca, typeVc = "x-score",
#  parAsColFcVn = genderFc, parEllipsesL = TRUE)

## ----pca-col_figure, echo = FALSE------------------------------------------
genderFc <- sampleMetadata[, "gender"]
plot(sacurine.pca, typeVc = "x-score",
parAsColFcVn = genderFc, parEllipsesL = TRUE, parDevNewL = FALSE)

## ----plsda, eval = FALSE---------------------------------------------------
#  sacurine.plsda <- opls(dataMatrix, genderFc)

## ----plsda_figure, echo = FALSE--------------------------------------------
sacurine.plsda <- opls(dataMatrix, genderFc, plotL = FALSE)
layout(matrix(1:4, nrow = 2, byrow = TRUE))
for(typeC in c("permutation", "overview", "outlier", "x-score"))
plot(sacurine.plsda, typeVc = typeC, parDevNewL = FALSE)

## ----oplsda, eval = FALSE--------------------------------------------------
#  sacurine.oplsda <- opls(dataMatrix, genderFc,
#  predI = 1, orthoI = NA)

## ----oplsda_figure, echo = FALSE-------------------------------------------
sacurine.oplsda <- opls(dataMatrix, genderFc,
predI = 1, orthoI = NA, plotL = FALSE)
layout(matrix(1:4, nrow = 2, byrow = TRUE))
for(typeC in c("permutation", "overview", "outlier", "x-score"))
plot(sacurine.oplsda, typeVc = typeC, parDevNewL = FALSE)

## ----oplsda_subset, eval = FALSE-------------------------------------------
#  sacurine.oplsda <- opls(dataMatrix, genderFc, predI = 1, orthoI = NA,
#  subset = "odd")

## ----oplsda_subset_code, echo = FALSE--------------------------------------
sacurine.oplsda <- opls(dataMatrix, genderFc, predI = 1, orthoI = NA, permI = 0,
subset = "odd", plotL = FALSE)

## ----train-----------------------------------------------------------------
trainVi <- getSubsetVi(sacurine.oplsda)
table(genderFc[trainVi], fitted(sacurine.oplsda))

## ----test------------------------------------------------------------------
table(genderFc[-trainVi],
      predict(sacurine.oplsda, dataMatrix[-trainVi, ]))

## ----overfit, echo = FALSE-------------------------------------------------
set.seed(123)
obsI <- 20
featVi <- c(2, 20, 200)
featMaxI <- max(featVi)
xRandMN <- matrix(runif(obsI * featMaxI), nrow = obsI)
yRandVn <- sample(c(rep(0, obsI / 2), rep(1, obsI / 2)))

layout(matrix(1:4, nrow = 2, byrow = TRUE))
for(featI in featVi) {
    randPlsi <- opls(xRandMN[, 1:featI], yRandVn,
                  predI = 2,
                  permI = ifelse(featI == featMaxI, 100, 0),
                  printL = FALSE, plotL = FALSE)
    plot(randPlsi, typeVc = "x-score", parDevNewL = FALSE,
         parCexN = 1.3, parTitleL = FALSE)
    mtext(featI/obsI, font = 2, line = 2)
    if(featI == featMaxI)
         plot(randPlsi, typeVc = "permutation", parDevNewL = FALSE,
           parCexN = 1.3)
    }
mtext(" obs./feat. ratio:", adj = 0, at = 0, font = 2, line = -2, outer = TRUE)

## ----vip, echo = FALSE-----------------------------------------------------
ageVn <- sampleMetadata[, "age"]

pvaVn <- apply(dataMatrix, 2,
               function(feaVn) cor.test(ageVn, feaVn)[["p.value"]])

vipVn <- getVipVn(opls(dataMatrix, ageVn, predI = 1, orthoI = NA, plot = FALSE))

quantVn <- qnorm(1 - pvaVn / 2)
rmsQuantN <- sqrt(mean(quantVn^2))

par(font = 2, font.axis = 2, font.lab = 2, las = 1,
    mar = c(5.1, 4.6, 4.1, 2.1),
    lwd = 2, pch = 16)

plot(pvaVn, vipVn,
     col = "red",
     pch = 16,
     xlab = "p-value", ylab = "VIP", xaxs = "i", yaxs = "i")

box(lwd = 2)

curve(qnorm(1 - x / 2) / rmsQuantN, 0, 1, add = TRUE, col = "red", lwd = 3)

abline(h = 1, col = "blue")
abline(v = 0.05, col = "blue")

## ----expressionset_code, eval = FALSE--------------------------------------
#  library(Biobase)
#  sacSet <- ExpressionSet(assayData = t(dataMatrix),
#  phenoData = new("AnnotatedDataFrame", data = sampleMetadata))
#  opls(sacSet, "gender", orthoI = NA)

## ----expressionset_figure, echo = FALSE, message = FALSE, warning = FALSE----
library(Biobase)
sacSet <- ExpressionSet(assayData = t(dataMatrix),
phenoData = new("AnnotatedDataFrame", data = sampleMetadata))
eset.oplsda <- opls(sacSet, "gender", orthoI = NA, plotL = FALSE)
layout(matrix(1:4, nrow = 2, byrow = TRUE))
for(typeC in c("overview", "outlier", "x-score", "x-loading"))
plot(eset.oplsda, typeVc = typeC, parDevNewL = FALSE)

## ----fromW4M---------------------------------------------------------------
sacSet <- fromW4M(file.path(path.package("ropls"), "extdata"))
sacSet

## ----toW4M, eval = FALSE---------------------------------------------------
#  toW4M(sacSet, paste0(getwd(), "/out_"))

## ----detach----------------------------------------------------------------
detach(sacurine)

## ----sessionInfo, echo=FALSE-----------------------------------------------
sessionInfo()

