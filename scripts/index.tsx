/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import React from 'react';
import ReactDOM from 'react-dom';
import App from '@/components/App';

import './i18n';

// Auto-load all plugin registers
const pluginContext = require.context('./plugins', true, /register\.tsx?$/);
pluginContext.keys().forEach(pluginContext);

ReactDOM.render(<App />, document.getElementById('app'));
