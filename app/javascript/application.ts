// Entry point for the build script in your package.json
import "@hotwired/turbo-rails";
import "@rails/activestorage";

import "./controllers/index";

Turbo.session.drive = false;
