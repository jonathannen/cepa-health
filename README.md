# Cepa Health Check for Rack-based Applications

Cepa Health is a Rack Middleware that provides "probes". A probe is a block
of code executed when the `/healthy` path is accessed. This path will return
a list of the probe results, most importantly with the HTTP Status Code of
"200 OK" for an overall successful result, or a "500 Internal Server Error" if
any probe fails.

This path is intended for use by services such as 
[Pingdom](https://www.pingdom.com/) or [New Relic](http://newrelic.com/).
This path is also for use with Load Balancers that use a health check, such as
Amazon's [Elastic Load Balancer](http://aws.amazon.com/elasticloadbalancing/).

See Discussion before for more details on the use of Cepa Health.

## Installation

Add this line to your application's Gemfile:

    gem 'cepa-health'

And then execute:

    $ bundle

Equally you can install without a gemfile using:

	$ gem install cepa-health

## Usage

http://rubyonrails.org/
If you're running a Rails application, you can generate a default initializer with
    
    $ rails generate cepa_health:initializer

This will create a file `config/initializers/cepa_health.rb`. Refer to that file for more instructions.

Alternatively, if you're running a Rack-based application (e.g. using
[Sinatra Framework](http://www.sinatrarb.com/)) add the following to config.ru. Note this assumes you're running with [Bundler](http://bundler.io/sinatra.html) or loading the cepa-health gem yourself.

    use CepaHealth::Middleware

To define probes, register blocks as:
	
	# Create a Probe with the default level of "error"
	CepaHealth.register do
   		record("Other result", true, "This will add another reporting row")
   		["My Error Probe", true, "Comment"] # Ultimate result of the probe
	end

	# Create a Probe specifically tagged as level "warn"
	CepaHealth.register :warn do
   		record("Other result", true, "This will add another reporting row")
      ["My Warning Probe", true, "Comment"] # Ultimate result of the probe
	end
	
The result of these Probes is summarized at the `/healthy` path when you run 
your Rack application. This will render a HTML table, you can similarly use 
`/healthy.json` or `healthy.txt` for JSON and Text results respectively. Take 
a look at the [probes directory](https://github.com/jonathannen/cepa-health/tree/master/probes) 
for some examples of probes.

By default, `/healthy` will return all probes. You can cut this back using 
filters. For example, `healthy.txt?filters=warn` will return a Text summary 
of just the "warn" level Probes. `healthy.txt?filters=error,warn` returns both
"error" and "warn" probes.

## Privacy

You may not want your health check available to anyone - either because you
want to be private about the results, or you don't want to unnecessarily reveal
details of your stack. To provide an extra layer of privacy, you can set a key
on your health check. Just add (or comment out in the initalizer):

	CepaHealth.key = "sekret"

The health check will only be available if `key=sekret` is added to the path. 
If it doesn't match, a blank 404 is returned.

This will prevent casual access to your health check.

## Discussion

There are already a handful of Rack and Rails-based Health Checks. For example,
[rack-health](https://github.com/mirakui/rack-health) or
[rack-ping](https://github.com/jondot/rack-ping).

Cepa Health addresses a handful of specific needs:

- Different levels of probes. The "error" is appropriate for removing a server from a Load Balancer and raising alarms. The "warn" level may be less serious, such as a failed Delayed Job. You way still wish to raise an alert, but perhaps of different severity.
- Simiarly, there may be other needs for uptime reporting. In this case you may only wish to measure probes that directly affect site usage.
- Cepa Health can be stubbed out by simply adding a blank `healthy.txt` to the root directory of the given path.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Make sure you have some tests or way of validating the feature.
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
7. ... and thanks!

## License

MIT Licensed. See LICENSE.txt
