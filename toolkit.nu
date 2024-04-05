export def main [] {
    help toolkit
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

export def test [] {
    ls challenges
    | get name
    | each {|challengePath|
        let challengeId = $challengePath | path basename

        cd $challengePath
        | ls
        | where type == file and name in [in out cmd]
        | if ($in | length) != 3 {
            print $'($challengeId) (ansi red)FAIL(ansi yellow) (char lparen)in, out or cmd file missing(char rparen)(ansi reset)'
            {Fail: 1}
        } else {
            cp in test
            let keys = (open cmd | str replace --all "'" "''''")
            let cmd = $"
                map global user q ':write;kill<ret>'
                try 'exec -with-maps ''($keys)'''
                exec i 'did not quit' <esc>
                wq!
            "
            kak test -ui dummy -n -e $cmd
            let keyCount = count-keys (open cmd | str trim)

            if (open out) == (open test) {
                print $'($challengeId) (ansi green)SUCCESS(ansi yellow) (char lparen)($keyCount) keys(char rparen)(ansi reset)'
                {Success: 1}
            } else {
                print $'($challengeId) (ansi red)FAIL(ansi yellow) (char lparen)($keyCount) keys(char rparen)(ansi reset)'
                {Fail: 1}
            }
        }
    }
    | reduce --fold {Success: 0, Fail: 0} {|it, acc|
        {
            Success: ($acc.Success + ($it.Success? | default 0))
            Fail: ($acc.Fail + ($it.Fail? | default 0))
        }
    }
}

def count-keys [keys: string] {
    $keys
    | str replace --all --regex '<(?:[ac]-|)(?:.|ret|space|tab|lt|gt|backspace|esc|up|down|left|right|pageup|pagedown|home|end|backtab|del|minus|plus|semicolon|space)>' '0'
    | str length
}

def "str normalize" [] {
    lines
    | str join "\n"
    | $in ++ "\n"
}
