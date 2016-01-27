#!/usr/bin/env bats

load test_helper

_setup_search() {
  "$_NOTES" init
    cat <<HEREDOC | "$_NOTES" add
# one
idyl
HEREDOC
    sleep 1
    cat <<HEREDOC | "$_NOTES" add
# two
sweetish
HEREDOC
    sleep 1
    cat <<HEREDOC | "$_NOTES" add
# three
sweetish
HEREDOC
}

# `search` ####################################################################

@test "\`search\` exits with status 1 and prints help information." {
  {
    _setup_search
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "$_NOTES" search
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ $status -eq 1 ]]
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes search <query> [--path]" ]]
}

# `search <no match>` #########################################################

@test "\`search <no match>\` exits with status 1 and does not print output." {
  {
    _setup_search
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "$_NOTES" search 'no match'
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ $status -eq 1 ]]
  [[ -z "$output" ]]
}

# `search <one match> [--path]` ###############################################

@test "\`search <one match>\` exits with status 0 and prints output." {
  {
    _setup_search
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "$_NOTES" search 'idyl'
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ $status -eq 0 ]]
  [[ "${lines[0]}" =~ 20[0-9]+\.md$ ]]
  [[ "${lines[1]}" =~ -*-$ ]]
  [[ "${lines[2]}" =~ idyl ]]
}

@test "\`search <one match> --path\` exits with status 0 and prints path." {
  {
    _setup_search
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "$_NOTES" search 'idyl' --path
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ $status -eq 0 ]]
  [[ "${lines[0]}" =~ ${_NOTES_DATA_DIR}/20[0-9]+\.md$ ]]
  [[ "${#lines[@]}" -eq 1 ]]
}

# `search <multiple matches> [--path]` ########################################

@test "\`search <multiple matches>\` exits with status 0 and prints output." {
  {
    _setup_search
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "$_NOTES" search 'sweetish'
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  printf "\${lines[3]}: '%s'\n" "${lines[3]}"

  [[ $status -eq 0 ]]
  [[ "${lines[0]}" =~ 20[0-9]+\.md$ ]]
  [[ "${lines[1]}" =~ -*-$ ]]
  [[ "${lines[2]}" =~ sweetish ]]
  [[ "${lines[3]}" =~ 20[0-9]+\.md$ ]]
  [[ "${lines[4]}" =~ -*-$ ]]
  [[ "${lines[5]}" =~ sweetish ]]
  [[ "${lines[0]}" != "${lines[3]}" ]]
}

@test "\`search <multiple matches> --path\` exits with 0 and prints paths." {
  {
    _setup_search
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "$_NOTES" search 'sweetish' --path
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  printf "\${lines[0]}: '%s'\n" "${lines[0]}"

  [[ $status -eq 0 ]]
  [[ "${lines[0]}" =~ ${_NOTES_DATA_DIR}/20[0-9]+\.md$ ]]
  [[ "${lines[1]}" =~ ${_NOTES_DATA_DIR}/20[0-9]+\.md$ ]]
  [[ "${#lines[@]}" -eq 2 ]]
}