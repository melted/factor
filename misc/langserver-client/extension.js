// (c) 2019 Niklas Larsson
// See http://factorcode.org/license.txt for BSD license.

const vscode = require('vscode');
const langclient = require('vscode-languageclient');

let client = null;

/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {

	console.log('Activating factor-langserver');

    let factor = {
        command: "factor",
        args: ["-run=lang-server"],
        options: {}
    }

    let clientOpts = {
        documentSelector: [{ scheme: "file", language: "factor" }]
    }

    client = new langclient.LanguageClient('factor', factor, clientOpts)

    client.start()
}
exports.activate = activate;

// this method is called when your extension is deactivated
function deactivate() {
    if (client) {
        return client.stop()
    }
}

module.exports = {
	activate,
	deactivate
}
