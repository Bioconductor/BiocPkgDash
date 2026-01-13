#' Get the path to the config file
.get_config_path <- function() {
    tools::R_user_dir("BiocPkgDash", which = "config")
}

#' Get the config file
.get_config_file <- function() {
    file.path(.get_config_path(), "config.yml")
}

#' Create the config file if it doesn't exist
.create_config_file <- function() {
    config_path <- .get_config_path()
    if (!dir.exists(config_path)) {
        dir.create(config_path, recursive = TRUE)
    }
    config_file <- .get_config_file()
    if (!file.exists(config_file)) {
        file.create(config_file)
    }
}

#' Get the config
.get_config <- function() {
    .create_config_file()
    config::get(file = .get_config_file())
}

#' Set a config value
.set_config <- function(..., value) {
    .create_config_file()
    config <- .get_config()
    config[[...]] <- value
    yaml::write_yaml(config, .get_config_file())
}
