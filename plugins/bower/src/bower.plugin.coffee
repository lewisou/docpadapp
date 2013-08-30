bower = require('bower');
path = require('path');
fs = require('fs');

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
                fs.unlinkSync(v['dist'])
            fs.rmdir @ab_base_dir
            @js_files = {}

        docpadReady: (docpad) =>
            src_path = docpad.docpad.config.srcPath

            bower_conf = require(bower.config.cwd + '/bower.json').dependencies

            @relative_base_dir = path.join(@config['dir'] ? 'js', 'bower')
            @ab_base_dir = path.join(src_path, 'files', @relative_base_dir)
            fs.mkdirSync(@ab_base_dir) unless fs.existsSync(@ab_base_dir)

            for k, v of bower_conf
                file_name = "#{k}.js"
                @js_files[k] =
                    src: path.join(bower.config.cwd, bower.config.directory, k, file_name)
                    dist: path.join(@ab_base_dir, file_name)
                    path: path.join(@relative_base_dir, file_name)

            for k, v of @js_files
                fs.createReadStream(v['src']).pipe(fs.createWriteStream(v['dist']))

