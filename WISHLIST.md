## build tool to sync server validation messages with HTML5 validations

Right now HTML5 validation has different messages on each browser. Ideally we
would show the same validation messages that come up when validating
`ActiveRecord` models. We should build a tool that uses `setCustomValidity` to
customize the message to match what appears on the server. This would also help
us to test validations in system tests against both `Rack::Test`, Chrome, and
Firefox.

## make generic matchers for testing form errors with and without JS

`Rack::Test` does not implement HTML5 validation, so when submitting a form it
relies on server-side validation and the followup error messages when it
re-renders the form. Browsers, on the other hand, implement HTML5 validation,
so when testing against Firefox or Chrome, it prevents submitting the form in
the first place. When asserting against error messages in system tests, we
should have a tool that takes into account which driver is being used and
search for the error either in an errors div in the case of `Rack::Test` or for
JS enabled browsers we should be able to use:

```rb
page.find("#field_id").native.attribute("validationMessage")
```

This depends on the error messages being the same both in HTML5 validations and
in server rendered errors.
