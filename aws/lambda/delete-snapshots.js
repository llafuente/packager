var DRY_RUN = false;

//require('./credentials');
var AWS = require('aws-sdk');
var async = require('async');
var moment = require('moment');
AWS.config.region = 'eu-central-1';

// New EC2 object
var ec2 = new AWS.EC2();
var today = moment();

exports.handler = function(event, context, lambda) {

  ec2.describeTags({
    DryRun: DRY_RUN,
    Filters: [{
      Name: 'resource-type',
      Values: ['snapshot']
    },{
      Name: 'key',
      Values: ['delete-on']
    }],
    MaxResults: 1000 // TODO pagination...
  }, function(err, tags) {
    if (err) {
      return lambda(err);
    }

    console.log(tags.Tags);

    async.eachSeries(tags.Tags, (v, callback) => {
      if (moment(v.Value).isBefore(today)) {
        console.log(`${v.ResourceId} deleted`);

        return ec2.deleteSnapshot({
          SnapshotId: v.ResourceId,
          DryRun: DRY_RUN
        }, function(err, deletion_data) {
          if (err) {
            return callback(err);
          }

          console.log(deletion_data);
          callback();
        });
      }

      var x = moment(v.Value).diff(today, 'days');
      console.log(`${v.ResourceId} will be deleted in ${x} days`);
      callback();
    }, function(err) {
      lambda(err);
    });
  });
};
