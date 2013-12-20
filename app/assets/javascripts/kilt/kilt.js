var kilt = (function(){
    var self;
    return {
        init: function(){
            self = this;

            self.objectEdit();
            self.codemirror();

        },

        objectEdit: function() {

            $('.datepicker').datepicker();

        },
        
        codemirror: function() {
            
            var mixedMode = {
            name: "htmlmixed",
            scriptTypes: [{matches: /\/x-handlebars-template|\/x-mustache/i,
                           mode: null}]
            };
            
            $('textarea.html').each(function(){
                CodeMirror.fromTextArea(this,
                {
                    lineNumbers: true,
                    mode: mixedMode
                });
            });
            
        }
    };
})();
$(document).ready(function(){
    kilt.init();
});