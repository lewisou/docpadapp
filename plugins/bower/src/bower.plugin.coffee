bower = require('bower');
path = require('path');
fs = require('fs');

strEndsWith = (str, suffix) ->
    str.indexOf(suffix, str.length - suffix.length) != -1

module.exports = (BasePlugin) ->
    class BowerPlugin extends BasePlugin
        name: 'bower'
        constructor: ->
            super
            @js_files = {}

        renderBefore: ({templateData}, next) ->
            _this = this;
            templateData.bower_path = (name) ->
                _this.js_files[name].path
            next()

        generateAfter: =>
            for k, v of @js_files
                fs.unlinkSync(v['dist']) if fs.existsSync v['dist']
            fs.rmdir @ab_base_dir
            @js_files = {}

        docpadReady: (docpad) =>
            src_path = docpad.docpad.config.srcPath

            bower_conf = require(bower.config.cwd + '/bower.json').dependencies
            
            @relative_base_dir = path.join(@config['dir'] ? 'js', 'bower')
            @ab_base_dir = path.join(src_path, 'documents', @relative_base_dir)
            fs.mkdirSync(@ab_base_dir) unless fs.existsSync(@ab_base_dir)

            for k, v of bower_conf
                file_name = "#{k}.js"

                js_src_dir = path.join(bower.config.cwd, bower.config.directory, k)
                js_bowerjson = path.join(js_src_dir, 'bower.json')
                if fs.existsSync(js_bowerjson)
                    js_bowerjson_data = require(js_bowerjson)['main'] ? []
                    if typeof js_bowerjson_data == 'string'
                        file_name = js_bowerjson_data
                    else
                        mains = (f for f in js_bowerjson_data when strEndsWith(f, '.js'))
                        file_name = mains[0] if mains.length > 0

                @js_files[k] =
                    src: path.join(bower.config.cwd, bower.config.directory, k, file_name)
                    dist: path.join(@ab_base_dir, "#{k}.js")
                    path: path.join(@relative_base_dir, "#{k}.js")

            for k, v of @js_files
                if fs.existsSync(v['src'])
                    fs.createReadStream(v['src']).pipe(fs.createWriteStream(v['dist']))

