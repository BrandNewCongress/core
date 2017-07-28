to_delete="'"
empty=""
raw=`heroku config -s --remote bnc`
config=${raw//$to_delete/$empty}
echo $config
export $config
export MIX_ENV=dev
