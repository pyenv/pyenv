dir=$(dirname $0)

for plugin in ${dir}/plugins/*; do
    [ -d "${plugin}/bin" ] && export PATH="${plugin}/bin:$PATH"
done
export PATH="${dir}/bin:$PATH"

true # Return success exit code otherwise antigen breaks
