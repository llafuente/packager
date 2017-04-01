const chokidar = require('chokidar');
const spawn = require('child_process').spawn;
const pjoin = require('path').join;
const prelative = require("path").relative;

// cd ~/Desktop//Desktop/rauldelacruz.es/; node ~/vagrant/sv/rsync-folder.js ~/.ssh/aws-delacruzcafe.pem 'ec2-user@ec2-52-28-178-158.eu-central-1.compute.amazonaws.com' '/var/www/html/rauldelacruz.es/'
// node rsync-folder.js ~/.ssh/aws-delacruzcafe.pem 'ec2-user@52.57.67.55' '/var/www/html/'

/*

Readme
Syncronize CWD to a remote host using SCP/RSYNC over SSH

Troubleshooting

rsync error: some files/attrs were not transferred (see previous errors) (code 23) at main.c(1183) [sender=3.1.1]
** your use cannot write in target path


Error: *** ENOSPC
raise your syste limits:

sudo sysctl -a | grep ^fs.inotify

*/


const cwd = process.cwd();
const pem_file = process.argv[2];
const remote_user_host = process.argv[3];
const remote_path = process.argv[4];

var ignore = true;
setTimeout(function() {
	ignore = false;
}, 5000);

console.log('pem_file', pem_file);
console.log('remote_user_host', remote_user_host);
console.log('remote_path', remote_path);

chokidar.watch('.', {
  ignored: /[\/\\]\./
})
.on('add', rsync)
.on('change', rsync)
.on('unlink', rmrf)
.on('unlinkDir', rmrf)
.on('addDir', mkdirp);


function rsync(path) {
	if (ignore) return;

	path = prelative(cwd, path);
	var target = pjoin(remote_path, path);
	console.log('rsync', path, target);
	console.log('rsync', 'rsync', ["-avz", "-e", `ssh -i ${pem_file}`, path, `${remote_user_host}:${target}`], {
		encoding: 'utf8'
	});


	var r = spawn('rsync', ["-avz", "-e", `ssh -i ${pem_file}`, path, `${remote_user_host}:${target}`], {
		encoding: 'utf8'
	});
	r.stdout.on('data', log);
	r.stderr.on('data', log);
	r.on('close', (code) => {
	  console.log(`child process exited with code ${code}`);
	});

}

function rmrf(path) {
	if (ignore) return;

	path = prelative(cwd, path);
	var target = pjoin(remote_path, path);
	console.log('rmrf', path, target);

	var r = spawn('ssh', ["-i", pem_file, remote_user_host, `rm -rf ${target}`], {
		encoding: 'utf8'
	});
	r.stdout.on('data', log);
	r.stderr.on('data', log);
	r.on('close', (code) => {
	  console.log(`child process exited with code ${code}`);
	});	
}

function mkdirp(path) {
	if (ignore) return;

	path = prelative(cwd, path);
	var target = pjoin(remote_path, path);
	console.log('mkdirp', path, target);


	var r = spawn('ssh', ["-i", pem_file, remote_user_host, `mkdir -p ${target}`], {
		encoding: 'utf8'
	});
	r.stdout.on('data', log);
	r.stderr.on('data', log);
	r.on('close', (code) => {
	  console.log(`child process exited with code ${code}`);
	});		
}

function log(buffer) {
	console.log(buffer.toString('utf8'));
}