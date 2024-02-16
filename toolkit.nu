def "str normalize" [] {
    lines
    | str join "\n"
    | $in ++ "\n"
}

export def get-challenge [challengeId: string] {
    let challengePath = [challenges, $challengeId]
    | path join

    mkdir $challengePath

    http get $"https://vimgolf.com/challenges/($challengeId).json"
    | do {|response|
        $response.in.data
        | str normalize
        | save -f ($challengePath | path join in)

        $response.out.data
        | str normalize
        | save -f ($challengePath | path join out)
    } $in
}

export def main [] {
    help toolkit
}
