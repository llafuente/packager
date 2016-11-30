var SSH = require('simple-ssh');
var KV = require('./dynamodb-keyvalue');

exports.handler = function(event, context, lambda) {
  console.log(event);

  // TODO use payload to configure ssh connection
  // TODO use payload to include commands to execute

  var ssh = new SSH({
      host: '????',
      user: 'ec2-user',
      key: '-----BEGIN RSA PRIVATE KEY-----\n' +
'-----END RSA PRIVATE KEY-----'
  });

  ssh
  .exec('pwd', {
    out: console.log.bind(console),
    exit: function() {
        ssh.exec('echo "new queue"', {
          out: console.log.bind(console),
        });
        return false;
    }
  })
  .on('error', function(err) {
    console.log(err);
    lambda(err);
  })
  .on('ready', console.log.bind(console))
  //.on('close', console.log.bind(console))
  .start();
};
