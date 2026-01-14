.get_config_path <- function() {
    tools::R_user_dir("BiocPkgDash", which = "config")
}

.get_config_file <- function() {
    file.path(.get_config_path(), "config.yml")
}

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

.get_config <- function() {
    if (file.exists(.get_config_file()))
        yaml::read_yaml(.get_config_file())
}

.set_config <- function(...) {
    config <- list(...)
    .create_config_file()
    yaml::write_yaml(config, .get_config_file())
}

.config_file_exists <- function() {
    file.exists(.get_config_file())
}
