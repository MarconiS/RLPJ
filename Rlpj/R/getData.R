#' @title A function to process LPJ-GUESS outputs
#' @description This function reads the ASCII outputs produced by LPJ-GUESS.
#' It takes a list of output types (typeList) and finds them in the specified path.
#' The data is stored in a data class object: LPJData. If processing is TRUE,
#' the data will be stored as zoo time series. Ohterwise, as data frames.
#' @param x a character string indicating path to the output files
#' @param typeList  a character vector with the outputs to be analyzed.
#'  Default value is all
#' @param runInfo a named list with the information of the LPJ run
#' The runInfo it will be stored by the function as RData along with
#' the processed outputs of the model (optional)
#' @param processing a boolean indicating whether output files will be turned
#'  into time series (default is FALSE)
#' @return the processed data returned in a S4 Class: LPJData Class
#' @seealso \linkS4class{LPJData}, \url{https://cran.r-project.org/web/packages/zoo/zoo.pdf}
#' @author Ramiro Silveyra Gonzalez, Maurizio Bagnara, Florian Hartig
#' @note Based on an older code of Joerg Steinkamp
#' @details To convert the outputs into zoo time series is only supported when running the
#' model for one grid cell. For running  LPJ-GUESS for several grid cells, please set
#' processing to FALSE.
#' @export
#' @examples \dontrun{
#' LPJout <- getData( typeList = c("aaet",  "cflux","lai", "nflux"),
#'           "~/path/to/output/files", runInfo = list(parameter1 = 0.5, grid = 1))
#' }
getData <- function(x=NULL, typeList = NULL,  runInfo=NULL, processing = FALSE){
  # other options which could be included:
      #lon.extent=c(-180, 180), lat.extent=c(-90, 90),
      #area.weighted=FALSE, year.offset=0 ) {
      # @param lon.extent a numeric vector containing the min and max values used
      #  for west-east extent(default -180 to 180)
      # @param lat.extent a numeric vector containing the max and min values used
      #  for north-south extent (default 90 to -90).
      # @param area.weighted a boolean indicating whether the gridcells should be
      # weighted by their size (regular grids only, default FALSE).
      # @param year.offset a integer indicating the value to be added to the 'Year'
      #  column in the LPJ-GUESS output.


  # checking provided parameters
  #----------------------------------------------------------------------------#
  # CHECK INPUTS AND EXIT IF ANY ERROR
  #----------------------------------------------------------------------------#
  if(is.null(runInfo)){
    runInfo <- list(info = "No runInfo was passed")
  }
  if (is.null(x) || !file.exists(x)){
    stop("Please provide a valid directory")
  }
  if (is.null(typeList)){
    typeList <- typelist.default
    warning("Output type list has not been provided")
    warning("Setting type list to default values")
  }
  # checking directory existence
  if (!requireNamespace("zoo", quietly = TRUE)){
    stop("Can't load required library 'zoo'")
  }
  #----------------------------------------------------------------------------#
  # CHECK OUTPUTS IF NONE DATA IS NA
  #----------------------------------------------------------------------------#
  # Finding the files in path and checking if they exist
  keep <- rep(FALSE, length(typeList))
  for (i in 1:length(typeList)){
    if (file.exists(file.path(x, paste(typeList[[i]], ".out", sep="")))){
        if ( file.info( file.path(x, paste(typeList[[i]], ".out", sep="")) )[['size']] == 0){
        warning( paste("The",  typeList[[i]], ".out is empty!", sep = "") )
      }else{
        keep[i] <- TRUE
      }
    }else{
      warning( paste("There is no ",  typeList[[i]], ".out", sep = "") )
      }
    }
  if (any(keep)){
    typeList.valid <- typeList[keep]
    # Creating a list to hold data
    listData <- vector(mode="list", length=length(typeList.valid))
    names(listData) <- typeList.valid
  }else{
    stop("There are not model outputs. Please check the guess.log files")
  }

    # storing run info
  #LPJout@runInfo <- runInfo
  #----------------------------------------------------------------------------#
  # OBTAIN OUTPUTS:
  #----------------------------------------------------------------------------#
    if (processing == FALSE){
      # Adding Data to listData
      # looping over data types, reading files,  no processing data and adding it to the Data Class
      # list append data, probably will have to use the name() function to give it the right name
      # in the end, make the list of class LPJData
      # Add data to LPJout Data class
      for (j in 1:length(typeList.valid)) {
        data <- try(read.table(file.path(x, paste( typeList.valid[j], ".out", sep="")),header=T), TRUE)
        if ('try-error' %in% class(data)){
          data <- try(data <-readTableHeaderLPJ(file.path(x, paste( typeList.valid[j], ".out", sep=""))), TRUE)
          if ('try-error' %in% class(data)){
            stop("Model outputs are not readable")
          }
        }
        listData[[typeList.valid[[j]]]] <- data
      }
    }else{
      for (j in 1:length(typeList.valid)) {
      # Chekc how many grids in output
        data <- try(read.table(file.path(x, paste( typeList.valid[j], ".out", sep="")),header=T), TRUE)
        if ('try-error' %in% class(data)){
          data <- try(data <-readTableHeaderLPJ(file.path(x, paste( typeList.valid[j], ".out", sep=""))), TRUE)
          if ('try-error' %in% class(data)){
            stop("Model outputs are not readable")
          }
        }
        coordinates <- unique(paste(data$Lat, data$Lon, sep = "_"))

        if(length(coordinates) > 1 ){
          # Now we stop but eventually we want to do something out of this
          # Below there is code that would do it
          # This would also affect plotLPJData
          stop("Processing is not supported for more than one grid")
          # if only one grid, simplify the list
          #      if (length(listData) == 1){
          # listData <- listData[[1]]
          # Adding Data to listData
          # looping over data types, reading files, processing data and adding it to the Data Class
          # list append data, probably will have to use the name() function to give it the right name
          # in the end, make the list of class LPJData
          # Add data to LPJout Data class
          #coordinates <- lapply(coordinates, function(x){as.numeric(unlist(strsplit(x, "_")))})
          #listData <- rep(list(listData), length(coordinates))
          #names(listData) <- paste("grid", coordinates, sep = "_") # will need better named
          # Adding Data to listData
          # looping over data types, reading files, processing data and adding it to the Data Class
          # list append data, probably will have to use the name() function to give it the right name
          # in the end, make the list of class LPJData
          #keep <- rep(TRUE, length(coord))
          #sub_data <- coord[coord>=min(lon.extent) & Lon<=max(lon.extent) & Lat <=max(lat.extent) & Lat>=min(lat.extent))
          #for (k in 1:length(listData)){
          #  data <- data[data$Lat==coordinates[[k]][1] & data$Lon==coordinates[[k]][2],]

          #  for (j in 1:length(typeList.valid)) {
          #    # reading output
           #   data <- read.table(file.path(x, paste(typeList.valid[[j]], ".out", sep="")),header=T)
           #   data.ts  <- convertTS(data)
          #    listData[[k]][[typeList.valid[[j]]]] <- data.ts
           # }
          }else{
            data.ts  <- convertTS(data)
            listData[[typeList.valid[[j]]]] <- data.ts
        }
      }
    }
  # add it to the data class
  LPJout <- new(Class="LPJData",
                runInfo=runInfo,
                dataTypes=listData)
  #LPJout@dataTypes <- listData
  return (LPJout)
}

