awk '{
    match($0, /([^ ]+)\.c/, m)
    if (m[1] != "")
        sub(/-o [^ ]+\.o/, "-o " m[1] ".o")
    print
}' run-$config.sh > tmp && mv tmp run-$config.sh
