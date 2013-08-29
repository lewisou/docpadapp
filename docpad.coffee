# DocPad Configuration File
# http://docpad.org/docs/config

# Define the DocPad Configuration
docpadConfig = {
	# ...
    ignoreCommonPatterns: /~$/i
    ignoreCustomPatterns: /tpl\.jade$/
    plugins:
        assets:
            retainName: 'yes'


}

# Export the DocPad Configuration
module.exports = docpadConfig
