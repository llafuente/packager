var DRY_RUN = false;

//require('./credentials');
var AWS = require('aws-sdk');
var async = require('async');
var moment = require('moment');
AWS.config.region = 'eu-central-1';

// New EC2 object
var ec2 = new AWS.EC2();

var delete_on = moment().add(1, 'weeks').format('YYYY-MM-DD');
var today = moment().format('YYYY-MM-DD h:mm:ss')

exports.handler = function(event, context, lambda) {
  console.log(event);
  event = event || {};
  event['rule-name'] = event['rule-name'] || 'daily';

  ec2.describeTags({
    DryRun: DRY_RUN,
    Filters: [{
      Name: 'resource-type',
      Values: ['volume']
    },{
      Name: 'key',
      Values: ['backup']
    },{
      Name: 'value',
      Values: [event['rule-name']]
    }],
    MaxResults: 1000 // TODO pagination...
  }, function(err, tags) {
    if (err) {
      return lambda(err);
    }

    console.log(tags.Tags);

    async.eachSeries(tags.Tags, function(vol_data, callback) {
      ec2.createSnapshot({
        DryRun: DRY_RUN,
        VolumeId: vol_data.ResourceId,
        Description: `snapshot of ${vol_data.ResourceId} made at ${today}`,
      }, function(err, data) {
        if (err) {
          return callback(err);
        }

        console.log(data);

        ec2.createTags({
          Resources: [data.SnapshotId],
          Tags: [{
            Key: 'delete-on',
            Value: delete_on
          }]
        }, function(err, tag) {
          callback(err);
        });
      });
    }, function(err) {
      lambda(err);
    });
  });
};
