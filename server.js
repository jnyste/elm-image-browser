hound = require('hound');
express = require('express');
cors = require('cors');
fs = require('fs');
app = express();
app.use(cors());
allFiles = {files: []};

// Load initial files
function loadFiles() {

    newFiles = {files: []};

    fs.readdir('images/', function(err, items) {
        for (var i = 0; i < items.length; i++) {
            newFiles["files"].push({"filename": items[i]});
        }
    });

    return newFiles;
}

allFiles = loadFiles();

watcher = hound.watch('images');

watcher.on('create', function(file, stats) {
    allFiles = loadFiles();
});

watcher.on('delete', function(file) {
    allFiles = loadFiles();
});

var server = app.listen(3000, function() {
    console.log("Express server running.");
});

app.get('/files', function (req, res) {
    res.json(allFiles);
});

