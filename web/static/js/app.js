// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from './socket'
import modernizr from './modernizr'
import 'phoenix_html'
import fakeSpa from './fake-spa'
import littleAnalytics from './little-analytics'
import shareThis from "share-this";
import * as emailSharer from "share-this/dist/sharers/email";
import * as facebookSharer from "share-this/dist/sharers/facebook";
import * as twitterSharer from "share-this/dist/sharers/twitter";
import * as redditSharer from "share-this/dist/sharers/reddit";

fakeSpa.bind()
littleAnalytics.bind()

const selectionShare = shareThis({
    selector: "p",
    sharers: [ emailSharer, facebookSharer, twitterSharer, redditSharer ]
});

selectionShare.init();
