// Entry point for the build script in your package.json
import "@hotwired/turbo-rails";
import "@rails/activestorage";
import {session} from "@hotwired/turbo";

import "./controllers/index";

session.drive = false;

void navigator.serviceWorker.register("/service-worker.js");
