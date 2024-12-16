

<!DOCTYPE html>
<html lang="en" xml:lang="en" xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<style>
        #ad-block-test {
            width: 1px;
            height: 1px;
            position: absolute;
            left: -9999px;
            background: url(https://ads.example.com/ad.jpg) no-repeat;
        }
    	</style>
	</head>


	<body>
		<script>
    var dynamicContentRoot = '';
    var dynamicContentPrefix = '';
	var gtmOptions = { cookie_flags: 'secure;samesite=none' };
</script>

<script>

let HouseAds;
var shellLogo = 'img/logo.svg';

async function getAds() {
  const response = await fetch(dynamicContentPrefix + 'data/housePromo.json?' + Date.now());
  HouseAds = await response.json();
  if (HouseAds.shellLogo !== undefined && HouseAds.shellLogo.length > 0) {
		const useLogo = HouseAds.shellLogo.filter(logo => logo.active);
		if (useLogo.length > 0) {
			shellLogo = dynamicContentPrefix + 'data/img/art/' + useLogo[0].id + useLogo[0].imageExt;
		}
	}
}

getAds();

class Loader {

	constructor () {
		this.logo = '';
		this.blueWizSrcAlt = '';
	}

	static show () {
		let container = document.createElement('div');
		container.id = 'progress-container';
		container.style = `
			position: fixed;
			top: 0;
			left: 0;
			height: 100vh;
			width: 100vw;
			z-index: 2000;
			background-image: var(--ss-lightoverlay);
		`;

		const progressWrapper = document.createElement('div');
		progressWrapper.id = 'progress-wrapper';
		progressWrapper.className = 'load_screen align-items-center';
		progressWrapper.style = `
			position: absolute;
			left: 50%;
			top: -6em;
    		transform: translateX(-50%);
			background-image: none;
		`;

		const blueWizLogo = document.createElement('img');

		if (this.blueWizSrcAlt) {
			blueWizLogo.src = this.blueWizSrcAlt;
		} else {
			blueWizLogo.src = 'img/blueWizard_logo.webp';
		}

		blueWizLogo.style=`
			width: 16em;
			display: block;
			margin: 5em auto 0;
			z-index: 2000;
			position: absolute;
			left: 50%;
			bottom: 8em;
    		transform: translateX(-50%);
		`;

		this.logo = document.createElement('img');
		this.logo.src = shellLogo;
		this.logo.style = 'height: 16em';
		this.logo.id = 'logo-svg';
		// container.appendChild(logo);

		const progressOuter = document.createElement('div');
		progressOuter.id = 'progress-outer';
		progressOuter.style = `
			position: relative;
			background: #643219;
			border-radius: 2em;
			height: 3.3em;
			width: 24em;
			margin-top: 2em;
		`;


		let progress = document.createElement('div');
		progress.style = `
			margin-top: 1em;
			width: 23em;
			height: 2.2em;
			background: white;
			padding: 0.5em;
			border-radius: 2em;
    		margin: .3em .5em 0;
		`;
		container.appendChild(progress);

		let progressBar = document.createElement('span');
		progressBar.id = 'progressBar';
		progressBar.style = `
			display: block;
			width: 20%;
			height: 100%;
			background: orange;
			border-radius: 2em;
			margin-left: 80%;
			margin: 0 .3em .5em 0;
			opacity: 0;
			transition: margin-left linear 500ms;
			transition-timing-function: ease-in-out;
		`;

		const progressBarOutside = document.createElement('div');


		progress.appendChild(progressBar);
		progressWrapper.appendChild(this.logo);
		progressOuter.appendChild(progress);
		progressWrapper.appendChild(progressOuter);
		
		container.appendChild(progressWrapper);
		container.appendChild(blueWizLogo);

		// Minor for the progress bar intial load
		setTimeout(() => progressBar.style.opacity = 1, 600);


		Loader.barInterval = setInterval(() => {
			if (Loader.progressBar.style.marginLeft == '0%') {
				Loader.progressBar.style.marginLeft = '80%';
			}
			else {
				Loader.progressBar.style.marginLeft = '0%';
			}
		}, 500);

		Loader.progressBar = progressBar;
		Loader.container = container;

		let app = document.body;
		app.appendChild(container);
	}

	static hide () {
		Loader.container.style = "opacity : 0; transition: opacity 1s;";
		setTimeout(() => { Loader.container.remove(); }, 1000);
	}

	static addTask () {
		let id = Loader.loaded.length;
		//console.log('Loading tasks: ', ++Loader.actualTasks);
		Loader.loaded.push(0);
		return id;
	}

	static finish (id) {
		clearInterval(Loader.barInterval);

		if (Loader.progressBar) {
			Loader.progressBar.style.marginLeft = '0%';
			Loader.progressBar.style.transition = '';

			Loader.loaded[id] = 1;
			Loader.updateBar();
		}
	}

	static progress (id, value, total) {
		clearInterval(Loader.barInterval);

		if (Loader.progressBar) {
			Loader.progressBar.style.marginLeft = '0%';
			Loader.progressBar.style.transition = '';

			Loader.loaded[id] = value / total;

			Loader.updateBar();
		}

		return id;
	}

	static updateBar () {
		let loadedTotal = 0;

		for (let l of Loader.loaded) {
			loadedTotal += l;
		}
		let percent = loadedTotal / Loader.tasks * 95 + 5;
		// no more than 100%
		if (percent > 100) {
			percent = 100;
		}

		Loader.progressBar.style.width = percent + '%';
	}

	static loadJS (path, callback) {
		let p = path;

		(function (p, cb) {
			let xhr = new XMLHttpRequest();
  			xhr.open('GET', p, true);

			let id = Loader.addTask();

			xhr.onprogress = event => {
				if (Loader.progressBar) {
					id = Loader.progress(id, event.loaded, event.total);
				}
			};
  
			xhr.onload = () => {
				if (xhr.status != 200) {
      				console.log(`Error ${xhr.status}: ${xhr.statusText}`);
    			}
				else {
					Loader.finish(id);

					let script = document.createElement('script');
					script.innerHTML = xhr.response;
					document.body.appendChild(script);

					if (cb) cb();
				}
			};

			xhr.send();
		})(path, callback);
	}
}

Loader.actualTasks = 0;
Loader.tasks = 17;
Loader.loaded = [];

window.Loader = Loader;
window.indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB;

function openFirebaseDb () {
    return new Promise((resolve, reject) => {
        let req = window.indexedDB.open('firebaseLocalStorageDb');
        req.onsuccess = () => {
			let db = req.result;
			let transaction = db.transaction(['firebaseLocalStorage'], 'readwrite');
			let store = transaction.objectStore('firebaseLocalStorage');
			resolve({ db, store });
		}
		req.onerror = err => reject(err);
		req.onupgradeneeded = () => {
			let db = req.result;
			let store = db.createObjectStore('firebaseLocalStorage', { keyPath: 'fbase_key' });
			resolve({ db, store });
		}
    });
}

var redirectIframe

function postStorageAndRedirect (iframe, storage, firebaseDb) {
	iframe.contentWindow.postMessage({ storage, firebaseDb }, '*');
	window.location = 'https://shellshock.io' + window.location.search + window.location.hash;
}

// Loader.blueWizSrcAlt = 'img/blueWizard_logo_borg.webp';
Loader.show();

</script><!-- title, seo meta and favicons -->
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="facebook-domain-verification" content="6lfua33vx0abiv1asnt9p13aac29xy" />
<title>Shell Shockers 🍳 Multiplayer io game</title>
<meta name="Description" content="Blocked? Try geometry.monster | The OFFICIAL home of Shell Shockers, the world’s best egg-based shooter! It’s like your favorite FPS battlefield game… with eggs.">
<meta name="Keywords" content="Play, Free, Online, Multiplayer, Games, IO, ShellShockers, Shooter, Bullets, Top Down">
<meta name="author" content="Blue Wizard Digital">

<meta name="theme-color" content="#0B93BD" />
<meta name="background-color" content="#0B93BD" />

<link rel="icon" href="favicon.ico" type="image/x-icon">
<link rel="apple-touch-icon" href="favicon192.png" sizes="192x192" />
<link rel="icon" href="favicon256.png" sizes="512x512" />

<meta property="og:url"                content="https://www.shellshock.io" />
<meta property="og:type"               content="website" />
<meta property="og:image:width"        content="1000" />
<meta property="og:image:height"       content="500" />
<meta property="og:image"              content="https://www.shellshock.io/img/previewImage_shellShockers.webp" />
<meta name="image" property="og:image" content="https://www.shellshock.io/img/previewImage_shellShockers.webp" />
<meta property="og:title"              content="Shell Shockers | by Blue Wizard Digital" />
<meta property="og:description"        content="Blocked? Try geometry.monster | The OFFICIAL home of Shell Shockers, the world’s best egg-based shooter! It’s like your favorite FPS battlefield game… with eggs." />

<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:site" content="@eggcombat">
<meta name="twitter:creator" content="@eggcombat">
<meta name="twitter:title" content="Shell Shockers | by Blue Wizard Digital">
<meta name="twitter:description" content="Blocked? Try geometry.monster | The OFFICIAL home of Shell Shockers, the world’s best egg-based shooter! It’s like your favorite FPS battlefield game… with eggs.">
<meta name="twitter:image" content="https://www.shellshock.io/img/previewImage_shellShockers.webp">



<!-- Styles & Fonts -->
<link href="https://fonts.googleapis.com/css?family=Sigmar+One|Nunito:100,200,600,700,900" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.14.0/css/all.min.css" crossorigin="anonymous">
<link rel="stylesheet" href="styles/style.min.css?1733257169"><script>
function storageFactory(getStorage) {

	const inMemoryStorage = {};

	function isSupported() {
		try {
			var testKey = "__some_random_key_you_are_not_going_to_use__";
			getStorage().setItem(testKey, testKey);
			getStorage().removeItem(testKey);
			return true;
		} catch (e) {
			return false;
		}
	}

	function clear() {
		if (isSupported()) {
			getStorage().clear();
		} else {
			inMemoryStorage = {};
		}
	}

	function getItem(name) {
		if (isSupported()) {
			return getStorage().getItem(name);
		}

		if (inMemoryStorage.hasOwnProperty(name)) {
			return inMemoryStorage[name];
		}

		return null;
	}

	function key(index) {
		if (isSupported()) {
			return getStorage().key(index);
		} else {
			return Object.keys(inMemoryStorage)[index] || null;
		}
	}

	function removeItem(name) {
		if (isSupported()) {
			getStorage().removeItem(name);
		} else {
			delete inMemoryStorage[name];
		}
	}

	function setItem(name, value) {
		if (isSupported()) {
			getStorage().setItem(name, value);
		} else {
			inMemoryStorage[name] = String(value);
		}
	}

	function length() {
		if (isSupported()) {
			return getStorage().length;
		} else {
			return Object.keys(inMemoryStorage).length;
		}
	}

	return {
		getItem: getItem,
		setItem: setItem,
		removeItem: removeItem,
		clear: clear,
		key: key,

		get length() {
			return length();
		}

	};
	}

	const localStore = storageFactory(() => localStorage);
	const sessionStore = storageFactory(() => sessionStorage);
</script><style>
.eggIcon {
	display: inline-block;
	color: #444444;
	width: .8em;
	height: .8em;
	fill: currentColor;
}
</style>
						

<style>
.eggIconLocked {
	display: inline-block;
	color: #444444;
	width: .8em;
	height: .8em;
	fill: currentColor;
}
</style>
							
<svg style="position: absolute; width: 0; height: 0; overflow: hidden" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
	<defs>
		<symbol id="icon-egg-locked" viewBox="0 0 14.59 18.12">
<g>
	<path class="st0" d="M7.3,5.4c-0.6,0-1.1,0.5-1.1,1.1v1.3h2.2V6.5C8.4,5.9,7.9,5.4,7.3,5.4z"/>
	<path class="st0" d="M7.5,0.1c-4,0-7.4,6.7-7.4,10.7S3.4,18,7.3,18c3.9,0,7.2-3.2,7.2-7.2S11.5,0.1,7.5,0.1z M11.3,12.5
		c0,0.9-0.7,1.6-1.6,1.6H4.8c-0.9,0-1.6-0.7-1.6-1.6V7.8h1.5V6.5C4.8,5.1,5.9,4,7.3,4c1.4,0,2.5,1.1,2.5,2.5v1.3h1.5V12.5z"/>
</g>
		</symbol>
	</defs>
</svg><!-- ParsedURL -->
<script>
    var parsedUrl = (function parseUrl () {
        var url = {};
        var loc = window.location;
        url.root = loc.origin + loc.pathname;
        var query = loc.search.substring(1).split('&');
        url.query = {};
        for (let i = 0; i < query.length; i++)  {
            var arr = query[i].split('=');
            if (arr[0]) {
                if (arr[1] === undefined) {
                    arr[1] = true;
                } else if (!isNaN(arr[1])) {
                    arr[1] = parseFloat(arr[1]);
                }
                url.query[arr[0]] = arr[1];
            }
        }
        url.hash = loc.hash.substring(1);

        var host = loc.host.split('.');

        url.dom = host[0];
        url.top = host[1];

        if (url.hash.length == 0) url.hash = undefined;
        return url;
    })();
</script>
<!-- third party globals -->
<script>

	var pokiActive = false,
		crazyGamesActive = false,
		thirdPartyAdblocker = false,
		testCrazy = false;

	let crazyGamesHouseAdCheck = null;

		// we need a getter and setter for the vue instance
		const getCrazyGamesActive = {
			_value: '',
			set value(newValue) {
				this._value = newValue;
				crazyGamesActive = newValue;
				triggerCheck(newValue);
			},
			get value() {
				return this._value;
			}
		};

		function triggerCheck(value) {
			if (crazyGamesHouseAdCheck) {
				crazyGamesHouseAdCheck.isCrazyGames = value;
			}
		}

	class CrazyGames {
		constructor() {
			this.initialized = false;
			this.crazysdk = null;
			this.thirdPartyAdblocker = false;
		}

		async init() {
			if (!window.CrazyGames || !window.CrazyGames.SDK) {
				console.log("CrazyGames SDK not available");
				return;
			}

			try {
				await window.CrazyGames.SDK.init();
				this.crazysdk = window.CrazyGames.SDK;
				this.thirdPartyAdblocker = await this.crazysdk.ad.hasAdblock();
				this.initialized = true;
				crazyGamesActive = true;
				getCrazyGamesActive.value = true;
				console.log("CrazyGames SDK initialized successfully.");
			} catch (error) {
				console.error("Failed to initialize CrazyGames SDK:", error);
			}
		}
		async performAction(action, ...args) {
        if (!this.initialized) {
            return;
        }

        try {
            const result = action.call(this, ...args);
            if (result instanceof Promise) {
                await result;
            }
        } catch (error) {
            console.error("Error performing action:", error);
        }
    }

		inviteLink(invite) {
			if (!this.initialized) {
				return;
			}

			return this.crazysdk.game.inviteLink(invite);

		}

		async requestBanner(banner) {
			try {
				await this.performAction(() => this.crazysdk.banner.requestBanner(banner));
			} catch (error) {
				console.error("Error requesting banner:", error);
			}
    	}

		async requestResponsiveBanner(banner) {
			try {
				await this.performAction(() => this.crazysdk.banner.requestResponsiveBanner(banner));
			} catch (error) {
				console.error("Error requesting responsive banner:", error);
			}
		}

		clearAllBanners() {
			this.performAction(() => this.crazysdk.banner.clearAllBanners());
		}

		showInviteButton(invite) {
			this.performAction(() => this.crazysdk.game.showInviteButton(invite));
		}

		hideInviteButton() {
			this.performAction(() => this.crazysdk.game.hideInviteButton());
		}

		requestAd(type, callbacks) {
			this.performAction(() => this.crazysdk.ad.requestAd(type, callbacks));
		}

		gameplayStop() {
			this.performAction(() => this.crazysdk.game.gameplayStop());
		}

		gameplayStart() {
			this.performAction(() => this.crazysdk.game.gameplayStart());
		}

		adBlocker() {
			return this.initialized ? this.thirdPartyAdblocker : undefined;
		}
	}

    // Third party globals
	function initializeCrazyGamesSDK() {
		if (!window.crazySdk) {
			window.crazySdk = new CrazyGames();
			window.crazySdk.init();
		} else {
			console.log("CrazyGames SDK is already initialized.");
		}
	}

	window.addEventListener('load', initializeCrazyGamesSDK);

</script><!-- Crazy Games -->
<!-- European Union detection -->
<script>isFromEU = 0 ? true : false</script>
<!-- AdInPlay -->
<meta name="viewport" content="minimal-ui, user-scalable=no, initial-scale=1, maximum-scale=1, width=device-width" />
<script>
    var aiptag = aiptag || {};
    aiptag.cmd = aiptag.cmd || [];
    aiptag.cmd.display = aiptag.cmd.display || [];
    aiptag.cmd.player = aiptag.cmd.player || [];
</script>

        <script async src="//api.adinplay.com/libs/aiptag/pub/SSK/shellshock.io/tag.min.js"></script>
<!-- GTM -->
<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-79NWRZXYCB"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-79NWRZXYCB', gtmOptions);
</script>

<!-- Google Tag Manager -->
<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
})(window,document,'script','dataLayer','GTM-K5MSJHJ');</script>
<!-- End Google Tag Manager --><!-- In house ads -->
<script>
    window.googletag = window.googletag || {cmd: []};
    let inHouseSlot;
    const slots = [];

    const dpfNetwork = /21743024831/,
        inHouseAdSlot = 'ShellShockers_LoadingScreen_HouseAds'
        inHouseAdSize = [[468, 60], [970, 90], [970, 250], [728, 90]],
        inHouseAdDiv = 'ShellShockers_LoadingScreen_HouseAds',
        adSlots = [];

    // Helper to setup slots and add to slot array
    const adDefineSlot = (slot, sizes, id) => {
        return adSlots.push([{slot, sizes, id}]);
    };

    // Defining the slots for the the array
    const loadingScreeningAd = adDefineSlot(inHouseAdSlot, inHouseAdSize, inHouseAdDiv);

    // Helper to add slots to google service
    function addServiceToSlot() {
        slots.forEach(slot => {
            slot.addService(googletag.pubads());
        });
    }

    // Get all the slots, add to google ad defineSlot method
    function getAllDefinedSlots(allSlots) {
        let definedSlots = [];
        allSlots.forEach(adSlot => {
            for (var i = 0, len = adSlot.length; i < len; i++) {
                slots.push(googletag.defineSlot(dpfNetwork + adSlot[i].slot, adSlot[i].sizes, adSlot[i].id));
            }
        })
        return addServiceToSlot(slots);
    }

    const gtagInHouseLoadingBannerIntialLoad = () => {
        if (typeof hasPoki !== 'undefined') {
            console.log('haspoki', typeof(hasPoki));
            return; 
        }
        googletag.cmd.push(function() {
            getAllDefinedSlots(adSlots);
            googletag.pubads().disableInitialLoad();
            googletag.enableServices();
        });
    };

    gtagInHouseLoadingBannerIntialLoad();

    const adRenderedEvent = () => {
        return googletag.pubads().addEventListener('slotRenderEnded', (event) => {
            vueApp.disaplyAdEventObject(event);
        });
    };

    const gtagInHouseLoadingBanner = () => {
        googletag.cmd.push(function() {
            googletag.pubads().refresh([slots[0]]);
            adRenderedEvent();
        });
    };

    const destroyInhouseAdForPaid = () => {
        googletag.destroySlots([slots[0]]);
    };

</script><!-- Firebase -->
<script src="https://www.gstatic.com/firebasejs/9.17.2/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.17.2/firebase-auth-compat.js"></script>

<script src="https://www.gstatic.com/firebasejs/ui/6.0.2/firebase-ui-auth.js"></script>
<link type="text/css" rel="stylesheet" href="https://www.gstatic.com/firebasejs/ui/6.0.2/firebase-ui-auth.css" />
<!-- Facebook -->
<!-- Facebook Pixel Code -->
<script>
	!function(f,b,e,v,n,t,s){if(f.fbq)return;n=f.fbq=function(){n.callMethod?
	n.callMethod.apply(n,arguments):n.queue.push(arguments)};if(!f._fbq)f._fbq=n;
	n.push=n;n.loaded=!0;n.version='2.0';n.queue=[];t=b.createElement(e);t.async=!0;
	t.src=v;s=b.getElementsByTagName(e)[0];s.parentNode.insertBefore(t,s)}(window,
	document,'script','https://connect.facebook.net/en_US/fbevents.js');
	fbq('init', '771186996377132');
	fbq('track', 'PageView');
</script>
<noscript>
	<img height="1" width="1" style="display:none" src="https://www.facebook.com/tr?id=771186996377132&ev=PageView&noscript=1"/>
</noscript>
<!-- DO NOT MODIFY -->
<!-- End Facebook Pixel Code -->
<!-- progressive web app -->
<!-- <button id="addToHomescreen" style="z-index:333;display: none; position:absolute; top:0px; right: 75%; cursor:pointer;" class="ss_button btn_yolk bevel_yolk">Add to your desktop!</button> -->

<script>
    let pwaBlockAds = false;

	// if ('serviceWorker' in navigator) {
    //             console.log("Will the service worker register?");
    //             navigator.serviceWorker.register('service-worker.js')
    //             .then(function(reg){
    //                     console.log("Yes, it did.");
    //             }).catch(function(err) {
    //                     console.log("No it didn't. This happened:", err)
    //             });
    // }

    if (window.matchMedia('(display-mode: standalone)').matches) { 
        pwaBlockAds = 'utm_source' in parsedUrl.query && parsedUrl.query.utm_source === 'homescreen';
	ga('send', 'event', 'pwa', 'desktop opened');
    }  
</script>	
<!-- Music audio tag -->
<audio id="theAudio" preload="metadata"></audio>
<!-- VueJS -->
<script src="./js/vue/vue.min.2.6.10.js"></script><!-- tools and varibles -->
<script src="https://cdn.jsdelivr.net/npm/fuse.js@6.6.2"></script>
<script>
	localStore.removeItem('brbTime');

	String.prototype.format = String.prototype.f = function() {
    var s = this,
        i = arguments.length;

    while (i--) {
        s = s.replace(new RegExp('\\{' + i + '\\}', 'gm'), arguments[i]);
    }
    return s;
};

// HTMLCanvasElement.prototype.getContext = function(origFn) {
// 	return function(type, attribs) {
// 	  attribs = attribs || {};
// 	  attribs.preserveDrawingBuffer = true;
// 	  return origFn.call(this, type, attribs);
// 	};
//   }(HTMLCanvasElement.prototype.getContext);

function getKeyByValue (obj, value) {
	// if (!obj && !value) {
	// 	return;
	// }
	for (var prop in obj) {
		if (obj.hasOwnProperty(prop)) {
			if (obj[prop] === value) {
				return prop;
			}
		}
	}
}

function objToStr (obj) {
	var str = JSON.stringify(obj, null, 4).replace(/\\|"/g, '');
	//str = str.replace(/\\|"/g, '');
	return str;
}

function detectChromebook() {
	return /\bCrOS\b/.test(navigator.userAgent);
}

function removeChildNodes (name) {
	var myNode = document.getElementById(name);
	while (myNode.firstChild) {
	    myNode.removeChild(myNode.firstChild);
	}
}

function logCallStack() {
	var stack = new Error().stack;
	console.log(stack);
}

function getRequest (url, callback) {
	if (url.startsWith('./')) url = url.slice(2);
	url = dynamicContentPrefix + url;

	var req = new XMLHttpRequest();
	if (!req) {
		return false;
	}

	if (typeof callback != 'function') callback = function () {};
	
	req.onreadystatechange = function(){
		if(req.readyState == 4) {
			return req.status === 200 ? 
				callback(null, req.responseText) : callback(req.status, null);
		}
	}
	req.open("GET", url, true);
	req.send(null);
	return req;
}

function hasValue (a) {
	return (a !== undefined && a !== null && a !== 0);
}

Array.prototype.shallowClone = function() {
	return this.slice(0);
}

function deepClone (o) {
	return JSON.parse(JSON.stringify(o));
}

function isString (value) {
	return typeof value === 'string' || value instanceof String;
}

const capitalize = (s) => {
	if (typeof s !== 'string') return ''
	return s.charAt(0).toUpperCase() + s.slice(1)
};

function isHttps() {
	//return true // TODOJOSH
    return (document.location.protocol == 'https:');
}

function elOverlap(el1, el2) {
	const domRect1 = el1.getBoundingClientRect();
	const domRect2 = el2.getBoundingClientRect();
  
	return !(
	  domRect1.top > domRect2.bottom ||
	  domRect1.right < domRect2.left ||
	  domRect1.bottom < domRect2.top ||
	  domRect1.left > domRect2.right
	);
  }

  function loadJS(FILE_URL, async = true, callback, errorCallback) {
	let scriptEle = document.createElement("script");
  
	scriptEle.setAttribute("src", FILE_URL);
	scriptEle.setAttribute("type", "text/javascript");
	scriptEle.setAttribute("async", async);
  
	document.body.appendChild(scriptEle);
  
	// success event 
	scriptEle.addEventListener("load", () => {
		if (callback) callback();
	  console.log("File loaded")
	});
	 // error event
	scriptEle.addEventListener("error", (ev) => {
		if (errorCallback) errorCallback();
	  console.log("Error on loading file", ev);
	});
  }

  function debounce(fn, wait){
	let timer;
	return function(...args){
		if(timer) {
			clearTimeout(timer); // clear any pre-existing timer
		}
		const context = this; // get the current context
		timer = setTimeout(()=>{
			fn.apply(context, args); // call the function if time expires
		}, wait);
   }
}	
function getStoredNumber (name, def) {
	var num = localStore.getItem(name);
	if (!num) {
		return def;
	}
	return Number(num);
}

function getStoredBool (name, def) {
	var str = localStore.getItem(name);
	if (!str) {
		return def;
	}
	return str == 'true' ? true : false;
}

function getStoredString (name, def) {
	var str = localStore.getItem(name);
	if (!str) {
		return def;
	}
	return str;
}

function getStoredObject (name, def) {
	var str = localStore.getItem(name);
	if (!str) {
		return def;
	}
	return JSON.parse(str);
}

function getSetIncrementStoredNum(name, set) {
	const val = localStore.getItem(name);
	if (val) {
		localStore.setItem(name, Number(val) + set);
	} else {
		localStore.setItem(name, set);
	}
	return Number(localStore.getItem(name));
}
	var shellColors = [
	'#ffffff',
	'#c4e3e8',
	'#e2bc8b',
	'#d48e52',
	'#cb6d4b',
	'#8d3213',
	'#5e260f',

	'#e70a0a',
	'#aa24ce',
	//'#f17ff9', // Old Pink
	'#E0219A', // Barbie Pink
	'#FFD700',
	'#33a4ea',
	'#3e7753',
	'#59db27',
	//'#99953a'
];

var freeColors = shellColors.slice(0, 7);
var paidColors = shellColors.slice(7, shellColors.length);

	const RESPAWNADUNIT = 'shellshockers_respawn_banner-sh';
	const RESPAWN2ADUNIT = 'shellshockers_respawn_banner_2-sh';
	const RESPAWN3ADUNIT = 'shellshockers_respawn_banner_3-sh';
	const  AIPSUBID = 'shellshock.io';

	var Slot = {
		Primary: 0,
		Secondary: 1
	};

	var EGGCOLOR = {
		white: 0,
		skyblue: 1,
		beige: 2,
		tan: 3,
		brown: 4,
		caramel: 5,
		chocolate: 6,
		red: 7,
		purple: 8,
		violet: 9,
		yellow: 10,
		babyblue: 11,
		darkgreen: 12,
		green: 13	
	}

	// Type matches contents of the item_type table (could be generated from a db query but ... meh)
	var ItemType = {
		Hat: 1,
		Stamp: 2,
		Primary: 3,
		Secondary: 4,
		Grenade: 6,
		Melee: 7
	}

	var CharClass = {
		Soldier: 0,
		Scrambler: 1,
		Ranger: 2,
		Eggsploder: 3,
		Whipper: 4,
		Crackshot: 5,
		TriHard: 6
	};

	const PurchaseType = {
		vip: 0,
		purchase: 1
	};

	const DmgType = [
		{ name: 'Eggk47' },
		{ name: 'Scrambler' },
		{ name: 'FreeRanger' },
		{ name: 'Cluck9mm' },
		{ name: 'Rpegg' },
		{ name: 'Whipper' },
		{ name: 'Crackshot' },
		{ name: 'TriHard' },
		{ name: 'Grenade' },
		{ name: 'Melee' },
		{ name: 'Fall' }
	];

	const SOCIALMEDIA = [
		'fa-facebook-square',
		'fa-instagram-square',
		'fa-tiktok',
		'fa-discord',
		'fa-youtube',
		'fa-twitter-square',
		'fa-twitch'
	];

	const ItemIcons = {
		Hat: '#ico-hat',
		Stamp: '#ico-stamp',
		Primary: '#ico-primary',
		Secondary: '#ico-secondary',
		Grenade: '#ico-grenade',
		Melee: '#ico-melee'
	};

	const PhotoBoothCMD = {
		size: 0,
		pose: 1,
		map: 2,
		color: 0,
		itemHide: 4,
		open: 5,
		close: 6,
		reset: 7,
		screenGrab: 8,
	};

	const ChallengePeriod = {
		0: {type: 'daily', period: 86400},
		1: {type: 'weekly', period: 604800},
		2: {type: 'monthly', period: 2592000},
	};

const ChallengeType = {
	0: 'kills',
	1: 'damage',
	2: 'deaths',
	3: 'movement',
	4: 'collect',
	5: 'timed',
	6: 'kotc',
	7: 'cts',
	8: 'ffa',
	9: 'items',
	10: 'eggsEarned',
	11: 'shop',
};

const ChallengeSubType = {
	0: 'killStreak',
	1: 'weaponType',
	2: 'damage',
	3: 'distance',
	4: 'jump',
	5: 'map',
	6: 'timePlayed',
	7: 'timeAlive',
	8: 'condition',
	9: 'color',
	10: 'kills',
	11: 'shot',
	12: 'hp',
	13: 'scoped',
	14: 'scope',
	15: 'death',
	16: 'oneShot',
	17: 'reload',
	18: 'collect',
	20: 'capturing',
	21: 'capture',
	22: 'contest',
	23: 'win',
};

const ChallengeConditions = {
	0: 'killstreak',
	1: 'weaponType',
	2: 'damage',
	3: 'distance',
	4: 'jump',
	5: 'map',
	6: 'timesPlayed',
	7: 'timeAlive',
	8: 'condition',
	9: 'color',
	10: 'kills',
	11: 'shot',
	12: 'hp',
	13: 'scoped',
	14: 'scope',
	15: 'oneShot',
	16: 'ammo',
	17: 'grenade',
	18: 'victim',
};

const ShellStreak = {
	HardBoiled: 1,
	EggBreaker: 2,
	Restock: 4,
	OverHeal: 8,
	DoubleEggs: 16,
	MiniEgg: 32
};

			/* Ranges
		Hat			1000 - 1999
		Stamp		2000 - 2999
		Secondary	3000 - 3099
		Soldier		3100 - 3399
		Range		3400 - 3599
		Scrambler	3600 - 3799
		Eggsploder	3800 - 3999
		Whipper		4000 - 4199
		Crackshot	4200 - 4499
		TriHard		4500 - < 16000
		Grenade		16000 - 16383
		*/

</script><!-- shellshockers js -->
<script>
	function ssJSComplete () {
		window.onloadingcomplete();
	}

	setTimeout(() => {
		Loader.loadJS('js/screenShot.js?1692215954');
		Loader.loadJS('js/shellshock.js?1733428483', ssJSComplete);
	}, 100);
</script>
		<!-- google tag manager noscript -->
		<!-- Google Tag Manager (noscript) -->
<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-K5MSJHJ"
height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<!-- End Google Tag Manager (noscript) -->		<svg width="0" height="0" style="position:absolute"><symbol viewBox="0 0 31.571 27.155" id="ico-backToGame" xmlns="http://www.w3.org/2000/svg"><path d="M2.057 26.506c-2.893-4.578-5.684-18.63 13.655-18.63h1.522V0L31.57 11.857 17.234 23.716V15.84h-4.35c-5.621 0-11.757 1.656-8.87 9.685.622 1.722-1.231 2.13-1.957.98Z"/></symbol><symbol xml:space="preserve" style="enable-background:new 0 0 24 19.9" viewBox="0 0 24 19.9" id="ico-checkmark" xmlns="http://www.w3.org/2000/svg"><path d="M10 18.2c-.2 0-.4-.1-.6-.2l-6.7-4.5c-.5-.3-.6-.9-.3-1.4l2.5-3.8c.2-.2.4-.4.7-.4h.1c.3 0 .6.1.8.3l3.4 3.1 6.8-9.1c.2-.2.5-.4.8-.4.3 0 .6.1.8.4l3.3 4c.3.4.3 1-.1 1.3L10.7 17.9c-.2.2-.5.3-.7.3z" style="fill:#f7ef1d"/><path d="m17.4 2.7 3.3 4L10 17.2l-6.7-4.5 2.5-3.8 4.2 3.8 7.4-10m0-2c-.7 0-1.2.3-1.6.8L9.7 9.8 7.1 7.4c-.3-.3-.8-.5-1.3-.5h-.2c-.6.1-1.2.4-1.5.9l-2.5 3.8c-.6.9-.4 2.2.5 2.8l6.7 4.5c.3.2.7.3 1.1.3.5 0 1-.2 1.4-.6L22.1 8.1c.7-.7.8-1.9.1-2.7l-3.3-4c-.3-.4-.9-.7-1.5-.7z" style="fill:#0c576f"/></symbol><symbol viewBox="0 0 18.703 34.574" id="ico-costDollar" xmlns="http://www.w3.org/2000/svg"><path d="M16.876 27.512c-1.219 1.391-2.86 2.306-4.923 2.744v1.793c0 .756-.214 1.366-.642 1.83s-.983.695-1.663.695-1.235-.232-1.663-.695-.642-1.074-.642-1.83v-1.646c-2.437-.341-4.522-1.134-6.256-2.379-.395-.268-.675-.572-.84-.914C.083 26.769 0 26.318 0 25.757c0-.732.192-1.366.577-1.903.383-.536.84-.805 1.366-.805.263 0 .527.05.79.146.264.098.604.281 1.02.55.966.584 1.867 1 2.701 1.243a9.456 9.456 0 0 0 2.667.366c1.163 0 2.047-.213 2.65-.64.605-.427.907-1.067.907-1.921 0-.512-.181-.933-.544-1.262-.362-.33-.813-.591-1.35-.787s-1.323-.439-2.354-.732c-1.646-.463-2.996-.932-4.05-1.408-1.054-.476-1.965-1.22-2.733-2.232C.877 15.36.494 14.001.494 12.293c0-1.952.614-3.646 1.844-5.086 1.23-1.439 2.854-2.39 4.874-2.853v-1.83c0-.732.219-1.335.658-1.81A2.147 2.147 0 0 1 9.516 0c.68 0 1.235.232 1.663.695s.642 1.073.642 1.83v1.72c1.822.316 3.6 1.084 5.334 2.304.396.292.675.616.84.969.165.354.247.787.247 1.3 0 .731-.198 1.366-.593 1.902s-.856.805-1.383.805a2 2 0 0 1-.757-.147c-.242-.097-.592-.28-1.053-.548a37.775 37.775 0 0 0-1.022-.604 8.013 8.013 0 0 0-1.695-.732 6.624 6.624 0 0 0-1.926-.274c-.988 0-1.79.238-2.404.713-.615.475-.922 1.116-.922 1.92 0 .782.35 1.367 1.054 1.757.702.39 1.81.781 3.325 1.17 1.625.416 2.958.855 4.001 1.318 1.042.463 1.943 1.207 2.7 2.232.757 1.024 1.136 2.402 1.136 4.134 0 1.976-.61 3.658-1.827 5.048Z"/></symbol><symbol viewBox="0 0 24.675 30.834" id="ico-costEgg" xmlns="http://www.w3.org/2000/svg"><path d="M12.612 0c6.814 0 12.063 12.114 12.063 18.774s-5.524 12.06-12.338 12.06S0 25.434 0 18.774 5.798 0 12.612 0Z"/></symbol><symbol viewBox="0 0 24 24" xml:space="preserve" id="ico-disabled" xmlns="http://www.w3.org/2000/svg"><g fill="#0B93BD"><path d="M12 24C5.4 24 0 18.6 0 12S5.4 0 12 0s12 5.4 12 12-5.4 12-12 12zm0-22C6.5 2 2 6.5 2 12s4.5 10 10 10 10-4.5 10-10S17.5 2 12 2z"/><path d="M19.8 20.8c-.3 0-.5-.1-.7-.3L3.5 4.9c-.4-.4-.4-1 0-1.4s1-.4 1.4 0l15.6 15.6c.4.4.4 1 0 1.4-.2.2-.5.3-.7.3z"/></g></symbol><symbol viewBox="0 0 24 24" xml:space="preserve" id="ico-egg-w-outline" xmlns="http://www.w3.org/2000/svg"><path class="afegg-fill" d="M12 21.6c-4.4 0-8-3.5-8-7.8 0-4 3.4-11.4 8.1-11.4 4.8 0 7.8 7.5 7.8 11.4.1 4.3-3.5 7.8-7.9 7.8z" style="fill-rule:evenodd;clip-rule:evenodd"/><path class="afegg-stroke" d="M12.1 3.9c3.6 0 6.3 6.4 6.3 9.9s-2.9 6.3-6.5 6.3-6.5-2.8-6.5-6.3c.1-3.5 3.2-9.9 6.7-9.9m0-3C6.2.9 2.5 9.4 2.5 13.8c0 5.2 4.3 9.3 9.5 9.3s9.5-4.2 9.5-9.3C21.5 9.4 18.2.9 12.1.9z"/></symbol><symbol viewBox="0 0 35.313 35.313" id="ico-fullscreen" xmlns="http://www.w3.org/2000/svg"><path d="M31.243 0h-19.91a4.074 4.074 0 0 0-4.07 4.07v13.21H4.07A4.074 4.074 0 0 0 0 21.351v9.892a4.074 4.074 0 0 0 4.07 4.07h9.892a4.074 4.074 0 0 0 4.07-4.07V28.05h13.211a4.074 4.074 0 0 0 4.07-4.07V4.07A4.074 4.074 0 0 0 31.243 0ZM14.526 31.244c0 .31-.253.563-.564.563H4.07a.564.564 0 0 1-.564-.563V21.35c0-.31.253-.564.564-.564h3.193v3.194a4.074 4.074 0 0 0 4.07 4.07h3.193v3.193Zm17.28-7.263c0 .31-.252.563-.563.563h-19.91a.564.564 0 0 1-.564-.563V4.07c0-.31.253-.564.564-.564h19.91c.31 0 .564.253.564.564v19.91Z"/></symbol><symbol viewBox="0 0 30.281 36.454" id="ico-goldenEgg" xmlns="http://www.w3.org/2000/svg"><path d="M15.14 36.45c9.214.215 16.596-7.384 14.897-17.837C28.537 9.395 21.957 0 15.14 0S1.744 9.395.245 18.613c-1.7 10.453 5.682 18.052 14.896 17.837Z" style="fill:#f7941d"/><path d="M21.984 7.734a.42.42 0 0 0 .346-.665c-1.55-2.204-6.684-8.21-12.969-1.834l-.061.066c-1.718 1.528-3.26 3.76-4.173 6.336-1.941 5.477-.647 10.123 2.658 11.294 3.305 1.172 8.42-2.123 10.362-7.6.725-2.043.945-4.06.77-5.849-.08-.818.483-1.56 1.301-1.647.66-.07 1.258-.11 1.766-.101Z" style="fill:#fab413"/><path d="M6.532 29.874c-.297-.103-.517.274-.283.483 2.236 1.995 7.782 5.884 14.261 2.568 7.119-3.643 7.38-11.682 6.402-15.857-.072-.308-.52-.284-.562.03-.392 2.92-1.934 9.49-7.948 12.181-5.194 2.324-9.717 1.342-11.87.595Z" style="fill:#ca7918"/><path d="M7.257 10.709s.697-3.93 4.722-6.338 4.468 1.807 2.313 2.979-4.257.087-7.035 3.359Z" style="fill:#fcd884"/></symbol><symbol xml:space="preserve" style="enable-background:new 0 0 30.3 36.5" viewBox="0 0 30.3 36.5" id="ico-goldenEgg-callout" xmlns="http://www.w3.org/2000/svg"><path d="M15.1 36.4c9.2.2 16.6-7.4 14.9-17.8C28.5 9.4 22 0 15.1 0S1.7 9.4.2 18.6c-1.7 10.5 5.7 18.1 14.9 17.8z" style="fill:#f7941d"/><path d="M22 7.7c.2 0 .4-.2.4-.4 0-.1 0-.2-.1-.2-1.5-2.2-6.7-8.2-13-1.8C7.6 6.8 6 9.1 5.1 11.6c-1.9 5.5-.6 10.1 2.7 11.3 3.3 1.2 8.4-2.1 10.4-7.6.7-2 .9-4.1.8-5.8-.1-.8.5-1.6 1.3-1.6.6-.1 1.2-.2 1.7-.2z" style="fill:#fab413"/><path d="M6.5 29.9c-.3-.1-.5.3-.3.5 2.2 2 7.8 5.9 14.3 2.6 7.1-3.6 7.4-11.7 6.4-15.9-.1-.3-.5-.3-.6 0-.4 2.9-1.9 9.5-7.9 12.2-5.2 2.3-9.7 1.3-11.9.6z" style="fill:#ca7918"/><path d="M7.3 10.7S8 6.8 12 4.4s4.5 1.8 2.3 3-4.3 0-7 3.3z" style="fill:#fcd884"/><path d="M13 21c-.5 0-.8-.1-.9-.1-.1-.1-.1-.4-.2-.9 0-.1-.1-.2-.1-.3v-1.1c0-.2-.1-.8-.3-1.8v-.5c0-.1-.1-.3-.1-.5V15c0-.4-.1-.6-.1-.7v-.4c0-.2 0-.5-.1-.9 0-.1 0-.3-.1-.6-.1-.6-.2-1.2-.2-1.6 0-.3-.1-.7-.2-1.1v-.1s.1 0 .1-.1c.3-.1.7-.2 1.2-.2h.7c.3 0 .5 0 .7-.1.1 0 .2 0 .4-.1h4.6c.1.1.2.1.3.2.3.1.5.2.7.4.1.1.1.2.1.4 0 .8-.1 1.4-.3 2l-.7 4v.2c-.1.1-.1.2-.1.4l-.1.4v.2c0 .4-.1.9-.2 1.6-.1.5-.3 1.2-.4 2 0 0 0 .1-.1.1s-.2.1-.3.1c-.3.1-1 .1-2.1.1H14c-.4-.1-.7-.1-1-.2zm2.7 7h-1.9c-.7 0-1.2 0-1.6-.1-.2 0-.3 0-.3-.1l-.1-2.4v-1.1c0-.1 0-.2.1-.3v-.5c0-.1 0-.2.1-.3.1-.1.2-.2.4-.2H16c.6 0 1.1 0 1.5.1.5.1.8.2.8.5V25c0 .1 0 .6.1 1.3v1c0 .3-.1.4-.1.6-.2.1-.3.1-.5.2h-.5c-.7 0-1.2 0-1.6-.1z" style="fill:#fff"/></symbol><symbol viewBox="0 0 58 58" id="ico-grenade" xmlns="http://www.w3.org/2000/svg"><path d="m41.24 26.11 1.95-2a1.91 1.91 0 0 0 0-2.71l-3.29-3.23.21-.21a1 1 0 0 0 0-1.45l-3.33-3.32a1 1 0 0 0-1.46 0l-1.92 1.93a4.57 4.57 0 1 0-5.28 7.31C23.8 23 19 25.21 16.69 27.57A10.18 10.18 0 0 0 17.07 42a10.18 10.18 0 0 0 14.4.3c3-3 6-9.87 5.32-14.68l.14.14a1.89 1.89 0 0 0 1.51.55L40 29.92a1.52 1.52 0 0 1 .29 1.65l-5.21 12.12 1.29.5a.88.88 0 0 0 1.05-.45l6.51-12.28a1.54 1.54 0 0 0-.09-1.59Zm-14.3-7.75a3.21 3.21 0 0 1 6.25-1.05l-2 2a1.91 1.91 0 0 0-.37 2.18 2.93 2.93 0 0 1-.67.07 3.21 3.21 0 0 1-3.21-3.2Z"/></symbol><symbol viewBox="0 0 58 58" id="ico-hat" xmlns="http://www.w3.org/2000/svg"><path d="M45.62 33a17.85 17.85 0 0 0-4.76-.7s-1.71-15.38-6-15.38c-2 0-4.32 2-5.9 2s-3.93-2-5.9-2c-4.25 0-6 15.38-6 15.38a17.85 17.85 0 0 0-4.76.7c-1.94.69-2.6 2.61-1.21 3.91 2.07 1.93 7.81 4 17.83 4.13 10-.16 15.76-2.2 17.83-4.13 1.47-1.28.81-3.2-1.13-3.91Z" style="fill:#fff"/></symbol><symbol viewBox="0 0 33.956 34.476" id="ico-map-size-large" xmlns="http://www.w3.org/2000/svg"><path d="M33.868 33.088 30.273 25.1a1.613 1.613 0 0 0-1.47-.95h-5.872a82.739 82.739 0 0 1-4.097 4.925l-1.842 2.033-1.841-2.033a82.739 82.739 0 0 1-4.098-4.926h-5.9a1.61 1.61 0 0 0-1.47.951L.088 33.088a.984.984 0 0 0 .898 1.388H32.97a.984.984 0 0 0 .898-1.388Z" class="alcls-1"/><path d="M16.992 27.408s1.185-1.308 2.75-3.258c3.057-3.806 7.569-10.062 7.569-13.831C27.31 4.619 22.69 0 16.992 0S6.673 4.62 6.673 10.319c0 3.769 4.512 10.025 7.569 13.831a79.831 79.831 0 0 0 2.75 3.258Zm-2.836-12.124V8.496c0-.347.104-.625.312-.833.208-.207.49-.31.846-.31.364 0 .652.103.864.31.212.208.317.486.317.833v5.988h2.924c.737 0 1.107.318 1.107.954 0 .322-.091.558-.274.712-.183.152-.46.228-.833.228h-4.182c-.347 0-.615-.093-.8-.28-.187-.186-.28-.457-.28-.814Z" class="alcls-1"/></symbol><symbol viewBox="0 0 33.956 34.476" id="ico-map-size-med" xmlns="http://www.w3.org/2000/svg"><path d="M30.273 25.1a1.613 1.613 0 0 0-1.47-.95h-5.872a82.739 82.739 0 0 1-4.097 4.926l-1.842 2.033-1.841-2.033a82.739 82.739 0 0 1-4.098-4.926h-5.9a1.61 1.61 0 0 0-1.47.951L.088 33.088a.984.984 0 0 0 .898 1.388H32.97a.984.984 0 0 0 .898-1.388L30.273 25.1Z" class="amcls-1"/><path d="M16.992 27.408s1.185-1.308 2.75-3.258c3.057-3.806 7.569-10.062 7.569-13.831C27.31 4.619 22.69 0 16.992 0S6.673 4.62 6.673 10.319c0 3.769 4.512 10.025 7.569 13.831a79.831 79.831 0 0 0 2.75 3.258ZM14.11 16.122c-.199.2-.457.298-.776.298-.308 0-.562-.097-.762-.29s-.297-.46-.297-.796v-7.21c0-.353.107-.64.324-.861s.492-.331.828-.331c.24 0 .455.068.65.205s.358.334.49.59l2.438 4.585 2.426-4.585c.273-.53.644-.795 1.113-.795.336 0 .61.11.821.33s.319.509.319.862v7.21c0 .336-.098.6-.292.795s-.45.291-.769.291c-.31 0-.562-.097-.761-.29s-.298-.46-.298-.796v-3.896l-1.511 2.783c-.15.282-.31.483-.478.602s-.367.18-.596.18-.429-.06-.596-.18c-.168-.119-.327-.32-.478-.602l-1.497-2.704v3.817c0 .326-.1.59-.298.788Z" class="amcls-1"/></symbol><symbol viewBox="0 0 33.956 34.476" id="ico-map-size-small" xmlns="http://www.w3.org/2000/svg"><path d="M30.273 25.1a1.613 1.613 0 0 0-1.47-.95h-5.872a82.739 82.739 0 0 1-4.097 4.926l-1.842 2.033-1.841-2.033a82.739 82.739 0 0 1-4.098-4.926h-5.9a1.61 1.61 0 0 0-1.47.951L.088 33.088a.984.984 0 0 0 .898 1.388H32.97a.984.984 0 0 0 .898-1.388L30.273 25.1Z" class="ancls-1"/><path d="M16.992 27.408s1.185-1.308 2.75-3.258c3.057-3.806 7.569-10.062 7.569-13.831C27.31 4.619 22.69 0 16.992 0S6.673 4.62 6.673 10.319c0 3.769 4.512 10.025 7.569 13.831a79.831 79.831 0 0 0 2.75 3.258ZM13.48 15.585c-.15-.114-.26-.233-.326-.357s-.098-.282-.098-.477c0-.265.079-.495.238-.69s.345-.291.557-.291c.114 0 .225.017.33.053.107.036.24.102.398.199.363.203.723.35 1.08.437.359.088.763.133 1.213.133.522 0 .916-.077 1.187-.232a.743.743 0 0 0 .403-.683c0-.203-.125-.378-.377-.523s-.731-.29-1.438-.431c-.874-.186-1.56-.406-2.054-.662-.495-.257-.842-.559-1.041-.908-.198-.349-.298-.77-.298-1.266 0-.565.168-1.078.504-1.537.336-.46.797-.82 1.385-1.08s1.248-.392 1.981-.392c.645 0 1.219.071 1.723.213.504.14.963.362 1.378.662.159.115.272.237.338.364.066.13.1.286.1.471 0 .265-.078.495-.232.69-.155.194-.338.29-.55.29-.115 0-.222-.014-.318-.045a2.16 2.16 0 0 1-.411-.206 10.59 10.59 0 0 0-.378-.205c-.207-.11-.45-.199-.729-.265s-.581-.1-.908-.1c-.45 0-.813.086-1.086.26-.274.171-.411.399-.411.68 0 .169.048.306.145.412.098.106.279.21.544.311.265.102.658.205 1.179.312.849.185 1.516.41 2.002.669.485.26.83.563 1.033.908s.305.751.305 1.219a2.54 2.54 0 0 1-.49 1.544c-.328.446-.785.79-1.372 1.034-.587.243-1.27.364-2.047.364a7.943 7.943 0 0 1-1.968-.231c-.606-.156-1.103-.37-1.491-.644Z" class="ancls-1"/></symbol><symbol viewBox="0 0 58 58" style="enable-background:new 0 0 58 58" xml:space="preserve" id="ico-melee" xmlns="http://www.w3.org/2000/svg"><path d="M12.4 46.3c.7.6 1.7.9 2.6.6.6-.2 1.2-.6 1.6-1.1L25 36c.2-.3.2-.6 0-.9v-.2l2.1-2.1h.1c3.1-.5 12.2-2.2 16.7-6.2 1.6-1.4 2.6-3.3 3-5.4.3-2.1 0-4.2-1.1-6.1-.6-1.2-1.6-2.2-2.8-2.8-1.8-1-4-1.4-6.1-1.1-2.1.3-4 1.4-5.4 3-4.1 4.6-5.8 13.6-6.2 16.7v.1l-2.2 2c-.3-.3-.7-.3-1 0l-9.8 8.4c-.5.4-.9 1-1.1 1.6-.3.9-.1 2 .7 2.7l.5.6zm20.4-31c1.4-1.6 3.4-2.6 5.6-2.6.5 0 .9 0 1.4.1-2.2.8-4.1 2.1-5.7 3.8-2.3 2.4-4.3 5.7-5.8 8.6.9-3.5 2.4-7.5 4.5-9.9zm2.6 2.6c2.3-2.5 4.8-3.6 6.6-3.6h.5L28.9 27.9c1.5-3.1 3.9-7.3 6.5-10zm8.3-2.4c.3 1.8-.8 4.5-3.6 7.1-2.8 2.6-6.9 4.9-10 6.5l13.6-13.6zm-1 9.7c-2.4 2.2-6.4 3.6-9.9 4.6 2.9-1.5 6.2-3.6 8.6-5.8 1.7-1.5 3-3.5 3.8-5.7.2 1.3.1 2.6-.3 3.8-.4 1.1-1.2 2.2-2.2 3.1z" style="fill:#fff"/></symbol><symbol viewBox="0 0 37.146 24.123" id="ico-nav-equipment" xmlns="http://www.w3.org/2000/svg"><path d="M35.197 16.086c-1.938-.688-4.76-.704-4.76-.704S28.723 0 24.475 0c-1.973 0-4.32 2.004-5.902 2.004S14.643 0 12.67 0C8.423 0 6.709 15.382 6.709 15.382s-2.822.016-4.76.704c-1.94.688-2.6 2.608-1.207 3.906 2.066 1.926 7.813 3.965 17.83 4.13 10.019-.165 15.766-2.204 17.832-4.13 1.392-1.298.732-3.218-1.207-3.906Z"/></symbol><symbol viewBox="0 0 43.927 30.364" id="ico-nav-friends" xmlns="http://www.w3.org/2000/svg"><path d="m38.849 15.363-.008-.002a6.921 6.921 0 0 0-.34-.086l-.034-.008a6.956 6.956 0 0 0-.32-.063l-.056-.01a6.98 6.98 0 0 0-.308-.043l-.069-.008a7.047 7.047 0 0 0-.312-.026l-.067-.005a7.063 7.063 0 0 0-.378-.011h-.08a6.26 6.26 0 0 0-4.893-11.438 10.81 10.81 0 0 1 .933 4.402c0 1.95-.527 3.832-1.48 5.468 3.902 1.977 6.478 6.035 6.478 10.524v2.91h6.012v-4.896a6.972 6.972 0 0 0-5.078-6.708Zm-33.77 0 .007-.002c.112-.032.226-.06.34-.086l.035-.008c.105-.024.212-.044.32-.063l.055-.01a6.98 6.98 0 0 1 .308-.043l.07-.008c.103-.012.207-.02.311-.026l.067-.005c.125-.007.251-.011.379-.011h.08a6.26 6.26 0 0 1 4.893-11.438 10.81 10.81 0 0 0-.934 4.402c0 1.95.527 3.832 1.48 5.468-3.902 1.977-6.478 6.035-6.478 10.524v2.91H0v-4.896a6.972 6.972 0 0 1 5.079-6.708Z" class="aqcls-1"/><path d="m28.483 15.415-.01-.003a8.895 8.895 0 0 0-.438-.11l-.044-.01a8.93 8.93 0 0 0-.412-.081c-.024-.005-.048-.01-.071-.013a8.975 8.975 0 0 0-.397-.055l-.09-.012a9.02 9.02 0 0 0-.401-.033l-.086-.007a9.11 9.11 0 0 0-.488-.013h-.103a8.064 8.064 0 1 0-7.96 0h-.102a8.98 8.98 0 0 0-8.98 8.98v6.306h26.125v-6.307c0-4.114-2.768-7.58-6.543-8.642Z" class="aqcls-1"/></symbol><symbol viewBox="0 0 32.36 31.597" id="ico-nav-home" xmlns="http://www.w3.org/2000/svg"><path d="M15.468.295.297 15.465c-.634.635-.185 1.72.712 1.72H4.57c.556 0 1.006.45 1.006 1.006V30.59c0 .556.451 1.007 1.007 1.007h4.91c.556 0 1.006-.451 1.006-1.007v-8.174c0-.556.451-1.007 1.007-1.007h5.345c.556 0 1.007.451 1.007 1.007v8.174c0 .556.45 1.007 1.007 1.007h4.91c.555 0 1.006-.451 1.006-1.007v-12.4c0-.556.45-1.006 1.007-1.006h3.562c.897 0 1.346-1.085.712-1.72L16.892.296a1.007 1.007 0 0 0-1.424 0Z"/></symbol><symbol viewBox="0 0 26.805 31.155" id="ico-nav-profile" xmlns="http://www.w3.org/2000/svg"><path d="m20.092 15.817-.01-.003a9.136 9.136 0 0 0-.45-.114l-.045-.01a9.18 9.18 0 0 0-.423-.083c-.025-.004-.049-.01-.073-.013a9.204 9.204 0 0 0-.407-.057l-.092-.011a9.276 9.276 0 0 0-.413-.035l-.087-.007a9.352 9.352 0 0 0-.501-.014h-.105a8.275 8.275 0 1 0-8.167 0h-.105A9.214 9.214 0 0 0 0 24.684v6.47h26.805v-6.47c0-4.221-2.84-7.777-6.713-8.867Z"/></symbol><symbol viewBox="0 0 33.411 31.155" id="ico-nav-shop" xmlns="http://www.w3.org/2000/svg"><path d="M33.124 5.345a1.35 1.35 0 0 0-1.055-.528H7.877l-.95-3.797A1.322 1.322 0 0 0 5.627 0h-4.29a1.336 1.336 0 1 0 0 2.672h3.27l5.415 22.083a1.32 1.32 0 0 0 1.3 1.02H26.76a1.336 1.336 0 1 0 0-2.673H12.342l-.773-3.13h17.3c.598 0 1.126-.421 1.301-.984l3.2-12.518a1.3 1.3 0 0 0-.246-1.125Z"/><circle cx="13.819" cy="29.01" r="2.145"/><circle cx="24.896" cy="29.01" r="2.145"/></symbol><symbol viewBox="0 0 58 58" id="ico-primary" xmlns="http://www.w3.org/2000/svg"><path d="m48.31 10.74-1.93 1.62a12.45 12.45 0 0 1-3.79-3.42l-.88.75A16.38 16.38 0 0 1 44.45 14l-.39.33L41.32 13l-1.52 1.21-.74-.44-5.23 4.3.12 1-.22.18-1.62-.48-2.39 2.18-.59-.37-.53.54 1.16 1.41L17 33l.2 3-1.2 2-1.39-.08-6.39 5.55L13 49l6.67-10.6.58-.25 3.94 10.91L29.08 45l-2.9-6.32 3.23-3-1.35-2.25c1.25 1.23 8.23 7.67 17.55 7.08l.57-6.88s-8 .58-13.25-5.32l.16-.57 10.15-8.92-.09-.82 6.63-5.72ZM25.62 37.42l-.71-1.56 1.64-.81-.2-.59-2 .14 2.11-1.42 1.34 2.21ZM12.9 20.87a5.82 5.82 0 0 0 1.75 1.31 5.64 5.64 0 0 0 2.15.59h.45a5.82 5.82 0 0 0 2.18-.41 6 6 0 0 0 1.86-1.16 5.85 5.85 0 0 0 1.9-3.92v-.45a6 6 0 0 0-1.58-4 6 6 0 0 0-1.75-1.31 5.87 5.87 0 0 0-2.15-.58h-.45a6 6 0 0 0-2.18.41 6.14 6.14 0 0 0-1.86 1.16 6 6 0 0 0-1.32 1.76 5.78 5.78 0 0 0-.59 2.15v.45a6 6 0 0 0 .42 2.13 6.22 6.22 0 0 0 1.17 1.87Zm2.24-7.79a.76.76 0 0 1 .63-.26h1.55a.83.83 0 0 1 .93.94v6.41a1 1 0 0 1-.26.74.87.87 0 0 1-.67.26 1 1 0 0 1-.7-.26 1 1 0 0 1-.26-.74v-5.61h-.59a.79.79 0 0 1-.63-.26.85.85 0 0 1-.23-.61.87.87 0 0 1 .23-.61Z" style="fill:#fff"/></symbol><symbol viewBox="0 0 44 39.001" id="ico-private-game-config" xmlns="http://www.w3.org/2000/svg"><rect class="avcls-1" y="4" width="44" height="4" rx="1.952" ry="1.952"/><circle class="avcls-1" cx="22.236" cy="6" r="6"/><rect class="avcls-1" y="31.001" width="44" height="4" rx="1.952" ry="1.952"/><circle class="avcls-1" cx="12" cy="33.001" r="6"/><rect class="avcls-1" y="17.501" width="44" height="4" rx="1.952" ry="1.952"/><circle class="avcls-1" cx="32.335" cy="19.501" r="6"/></symbol><symbol viewBox="0 0 58 58" id="ico-secondary" xmlns="http://www.w3.org/2000/svg"><path d="m43.75 16.19.79-.58-2.62-3.29-1.87 1.49-1.52-.81L37 14.12l.53 1.72L29 22.65l-1.39.08-6.38 5.1-.78-.65-1.35 1 .47 1-.7.56a.72.72 0 0 0-.17.93l3.16 5.27 2.22.33 4.33 9.48 2.64 1 4.56-4.37.27-2.72-2.37-5.37 5-4.59-2.25-3.3 2.8-2.4-.34-.89 5.61-4.58-.33-.48.63-.48Zm-7.31 13.27-3.57 3.31-.41-.93 1.67-1.66-2.52-1.47 2.36-2 .57.31Zm-14.38-7.83a5.87 5.87 0 0 0 1.31-1.76 5.68 5.68 0 0 0 .63-2.15v-.45a6 6 0 0 0-3.33-5.35 5.87 5.87 0 0 0-2.15-.58h-.45a6 6 0 0 0-4 1.58 6.16 6.16 0 0 0-1.32 1.75 5.68 5.68 0 0 0-.58 2.15v.45a5.91 5.91 0 0 0 1.58 4 6.16 6.16 0 0 0 1.75 1.32 5.83 5.83 0 0 0 2.15.59H18a6 6 0 0 0 2.18-.41 6.15 6.15 0 0 0 1.88-1.14Zm-5.81-.16a1.45 1.45 0 0 1-.84-.22.81.81 0 0 1-.31-.6 1.4 1.4 0 0 1 .44-.93l.77-.81.1-.1.71-.79.35-.39a3.28 3.28 0 0 0 .23-.28 9.49 9.49 0 0 0 .72-1.09 1.91 1.91 0 0 0 .21-.72.65.65 0 0 0-.2-.53.69.69 0 0 0-.54-.2.61.61 0 0 0-.53.22 2.34 2.34 0 0 0-.34.64 3 3 0 0 1-.33.65.71.71 0 0 1-.54.23.91.91 0 0 1-.65-.23 1 1 0 0 1-.28-.62 2.55 2.55 0 0 1 .38-1.35 2.9 2.9 0 0 1 1-1A3 3 0 0 1 18 13a2.54 2.54 0 0 1 1 .19 2.17 2.17 0 0 1 .85.51 2.39 2.39 0 0 1 .58.8 2.33 2.33 0 0 1 .21 1 2.75 2.75 0 0 1-.26 1.19 4.21 4.21 0 0 1-.58.94 11.56 11.56 0 0 1-.93 1.05 11.15 11.15 0 0 0-.87 1h2a.86.86 0 0 1 .64.25 1.11 1.11 0 0 1 .23.62.79.79 0 0 1-.25.61.78.78 0 0 1-.65.27Z" style="fill:#fff"/></symbol><symbol viewBox="0 0 33.956 34.086" id="ico-settings" xmlns="http://www.w3.org/2000/svg"><path d="m32.988 14.471-2.331-.412c-.48-.068-.892-.48-1.03-.891a17.065 17.065 0 0 0-.754-1.989c-.205-.411-.205-.96.138-1.372l1.44-1.92a1.245 1.245 0 0 0-.137-1.577l-1.098-1.166-1.097-1.166a1.245 1.245 0 0 0-1.577-.137l-1.92 1.371c-.412.275-.96.343-1.372.069a9.532 9.532 0 0 0-1.92-.823 1.254 1.254 0 0 1-.892-1.029l-.343-2.4C20.026.41 19.478 0 18.929 0h-3.155c-.617 0-1.097.411-1.234 1.029l-.412 2.332c-.069.48-.48.891-.96 1.028-.686.206-1.372.48-2.058.823-.411.206-.96.206-1.371-.137l-1.92-1.44a1.245 1.245 0 0 0-1.578.137L5.075 4.869 3.91 5.967a1.245 1.245 0 0 0-.137 1.577l1.372 1.989c.274.412.274.96.068 1.372a10.125 10.125 0 0 0-.823 1.989c-.137.48-.548.823-1.028.891l-2.332.343c-.55.069-1.03.617-1.03 1.166v3.155c0 .617.412 1.097 1.029 1.234l2.332.412c.48.068.891.411 1.028.891.206.686.48 1.372.755 1.99.205.41.205.96-.137 1.371l-1.44 1.92a1.245 1.245 0 0 0 .136 1.578l1.098 1.166 1.097 1.166c.412.411 1.097.48 1.578.137l1.988-1.372c.412-.274.96-.274 1.372-.069.617.343 1.303.618 1.989.823.48.138.823.55.892 1.03l.343 2.331c.068.617.617 1.029 1.165 1.029h3.155c.617 0 1.098-.412 1.235-1.029l.411-2.332c.069-.48.48-.891.892-1.029.617-.205 1.303-.48 1.852-.754.411-.206.96-.206 1.371.137l1.92 1.44c.48.343 1.166.275 1.578-.137l1.166-1.097 1.166-1.097c.411-.412.48-1.098.137-1.578l-1.372-1.92c-.274-.412-.274-.96-.068-1.372a9.533 9.533 0 0 0 .823-1.92c.137-.48.548-.823 1.028-.892l2.4-.343c.618-.068 1.03-.617 1.03-1.166v-3.154c.068-.755-.343-1.303-.96-1.372ZM16.94 23.935c-3.84 0-6.995-3.154-6.995-6.995s3.154-6.995 6.995-6.995 6.995 3.154 6.995 6.995-3.154 6.995-6.995 6.995Z"/></symbol><symbol viewBox="0 0 68 76.14" id="ico-shell-streak-restock" xmlns="http://www.w3.org/2000/svg"><path class="aycls-1" d="M61.54 40.75c-3.08 0-5.74 2.19-6.34 5.2-.1.5-.21.99-.35 1.48-.34-8.84-1.5-12.63-3.89-18.67a4 4 0 0 0-3.72-2.52c-1.64 0-3.11 1-3.72 2.52-.87 2.19-1.57 4.09-2.14 6.03-.56-1.95-1.27-3.84-2.14-6.03-.1-.26-.24-.5-.39-.73.12-.08.24-.17.36-.27L52 18.06c.15-.11.28-.23.41-.36a4.334 4.334 0 0 0 0-6.11c-.09-.09-.18-.18-.28-.26L39.72 1.07A4.296 4.296 0 0 0 36.89 0c-1.15 0-2.27.47-3.09 1.29-.78.78-1.22 1.83-1.23 2.97l-.08 3.39c-8.47.43-16.39 3.94-22.42 9.95l-.04.04C3.56 24.1 0 32.71 0 41.87c.01 9.18 3.57 17.78 10.02 24.23 6.46 6.46 15.07 10.03 24.22 10.04 9.16 0 17.76-3.56 24.23-10.04a34.146 34.146 0 0 0 9.4-17.66c.38-1.88-.11-3.82-1.34-5.32a6.436 6.436 0 0 0-5-2.36ZM33.06 27.11c-.54.43-.98.99-1.25 1.66-.87 2.19-1.57 4.09-2.14 6.03-.56-1.95-1.27-3.84-2.14-6.03a4 4 0 0 0-3.72-2.52c-1.64 0-3.11 1-3.72 2.52-2.55 6.42-3.69 10.3-3.95 20.39l-.08 2.95c-.01.41.05.82.17 1.22A21.13 21.13 0 0 1 12.88 42c-.02-5.76 2.2-11.16 6.25-15.22l.06-.06.1-.1a21.27 21.27 0 0 1 12.94-6l-.11 3.7v.12c0 1.01.34 1.93.93 2.67Zm-7.42 26.46c-.49.15-1.08.25-1.81.25-.36 0-.69-.03-.99-.07a4.86 4.86 0 0 1-1.46-.44c-.96-.47-1.29-1.1-1.29-1.1l.08-2.95c.25-9.84 1.37-13.22 3.67-19.02 2.3 5.8 3.42 9.18 3.67 19.02l.08 2.95s-.05.1-.18.25-.32.35-.61.55c-.29.2-.66.4-1.15.55Zm-1.81 4.26c2.62 0 4.57-.91 5.85-2.02 1.29 1.11 3.24 2.02 5.85 2.02s4.57-.91 5.85-2.02c1.29 1.11 3.24 2.02 5.85 2.02.43 0 .84-.03 1.23-.08-3.9 3.5-8.9 5.44-14.23 5.44-5.65 0-10.97-2.16-14.97-6.09-.3-.29-.57-.61-.85-.92 1.28.94 3.07 1.66 5.4 1.66Zm19.74-8.57c.02-.62.03-1.2.06-1.77.02-.57.05-1.11.08-1.63a67 67 0 0 1 .36-4.2c.15-1.25.34-2.37.57-3.42.6-2.8 1.45-5.09 2.6-7.99 2.3 5.8 3.42 9.18 3.67 19.02l.08 2.95s-.85 1.61-3.74 1.61-3.74-1.61-3.74-1.61l.08-2.95Zm-4.36 0 .08 2.95s-.85 1.61-3.74 1.61-3.74-1.61-3.74-1.61l.08-2.95c.25-9.84 1.37-13.22 3.67-19.02 2.3 5.8 3.42 9.18 3.67 19.02Zm24.74-1.59c-1.14 5.89-4.01 11.3-8.3 15.6-5.72 5.72-13.31 8.87-21.4 8.87-8.08 0-15.68-3.15-21.4-8.87-5.7-5.7-8.84-13.3-8.85-21.4 0-8.09 3.15-15.7 8.85-21.4l.04-.04c1.04-1.03 2.14-1.98 3.29-2.84 1.16-.86 2.37-1.64 3.62-2.32.42-.23.84-.45 1.27-.65.86-.41 1.73-.79 2.63-1.12 3.12-1.16 6.45-1.8 9.86-1.88l2.83-.07.18-7.21c0-.13.04-.19.07-.22 0 0 .03-.02.06-.05.01 0 .02-.01.04-.02.03-.02.07-.03.12-.04.02 0 .02-.01.04-.01h.06c.05.01.1.03.15.09l12.5 10.32c.12.12.12.33 0 .45L36.7 24.65s-.04.04-.07.05c0 0-.02 0-.03.01l-.09.03h-.02c-.04 0-.09 0-.14-.03-.2-.09-.2-.22-.2-.29l.25-8-2.99.09a25.3 25.3 0 0 0-6.95 1.21c-3.71 1.2-7.12 3.25-9.96 6.04l-.16.16c-4.82 4.82-7.45 11.23-7.42 18.06.03 6.8 2.72 13.16 7.57 17.93.61.6 1.25 1.16 1.9 1.69l.01.01a23.21 23.21 0 0 0 2.04 1.47c.69.44 1.39.85 2.11 1.22.01 0 .03.01.04.02.71.37 1.44.7 2.18 1 .02 0 .04.02.05.02.74.29 1.48.55 2.24.77.02 0 .05.02.07.02.75.22 1.51.4 2.27.55.03 0 .06.01.09.02.76.14 1.53.25 2.29.33.03 0 .07 0 .1.01.76.07 1.53.11 2.3.11h.13c.21 0 .42 0 .63-.01.19 0 .39 0 .58-.02.21-.01.42-.03.63-.04.19-.01.39-.02.58-.04.21-.02.42-.05.62-.07.19-.02.39-.04.58-.07.21-.03.41-.07.62-.1.2-.03.39-.06.59-.1.2-.04.41-.09.61-.13.19-.04.39-.08.58-.13.2-.05.39-.11.59-.16.2-.05.4-.1.59-.16.19-.06.39-.12.58-.19.2-.06.39-.12.59-.19.2-.07.39-.15.58-.22l.57-.21c.19-.08.38-.16.57-.25.19-.08.38-.16.56-.24.19-.09.37-.18.56-.27.18-.09.37-.18.55-.27.19-.1.37-.21.56-.31.18-.1.35-.19.53-.29.19-.11.37-.23.56-.35.17-.11.34-.21.5-.32.19-.12.37-.26.56-.39l.48-.33c.19-.14.37-.29.56-.43.15-.12.3-.23.45-.35.2-.17.4-.34.6-.52.12-.11.25-.21.37-.32.32-.29.63-.59.94-.89 3.59-3.59 6-8.14 6.96-13.06a2.425 2.425 0 0 1 .85-1.42c.21-.17.46-.31.72-.41s.55-.15.84-.15c.39 0 .75.09 1.07.24s.6.38.83.65c.22.27.39.59.48.93.05.17.07.35.08.53 0 .18 0 .37-.05.56Z" data-name="icons flat"/></symbol><symbol viewBox="0 0 58 58" id="ico-specialItem" xmlns="http://www.w3.org/2000/svg"><path d="M42.05 25.32h-8.88a.74.74 0 0 1-.71-.52l-2.75-8.44a.75.75 0 0 0-1.42 0l-2.75 8.44a.74.74 0 0 1-.71.52H16a.75.75 0 0 0-.44 1.35l7.19 5.22a.76.76 0 0 1 .27.84l-2.75 8.45a.75.75 0 0 0 1.16.83l7.18-5.22a.75.75 0 0 1 .88 0L36.62 42a.75.75 0 0 0 1.16-.83L35 32.73a.76.76 0 0 1 .27-.84l7.19-5.22a.75.75 0 0 0-.41-1.35Z" style="fill:#fff"/></symbol><symbol id="ico-stamp" viewBox="0 0 58 58" xmlns="http://www.w3.org/2000/svg"><defs><style>.bacls-1{fill:#fff}</style></defs><circle class="bacls-1" cx="26.49" cy="29.42" r="1.41"/><circle class="bacls-1" cx="31.86" cy="29.42" r="1.41"/><path class="bacls-1" d="M32.65 32.55a.91.91 0 0 0-1.11.64 2.4 2.4 0 0 1-4.64 0 .91.91 0 1 0-1.75.47 4.21 4.21 0 0 0 8.14 0 .91.91 0 0 0-.64-1.11Z"/><path class="bacls-1" d="M29 11c-8.2 0-14.86 13-14.86 21.22a14.86 14.86 0 0 0 29.72 0C43.86 24 37.2 11 29 11Zm.18 29.16a8.53 8.53 0 1 1 8.52-8.53 8.53 8.53 0 0 1-8.52 8.49Z"/></symbol><symbol viewBox="0 0 29.297 30.465" id="ico-star" xmlns="http://www.w3.org/2000/svg"><path d="m11.527.247 6.535 6.356a.87.87 0 0 0 .777.23l8.94-1.782a.87.87 0 0 1 .951 1.238l-4.024 8.18a.87.87 0 0 0 .021.81l4.457 7.952a.87.87 0 0 1-.884 1.287l-9.022-1.3a.87.87 0 0 0-.764.27l-6.186 6.696a.87.87 0 0 1-1.497-.442L9.28 20.759a.87.87 0 0 0-.493-.642l-8.28-3.815a.87.87 0 0 1-.042-1.56l8.064-4.252a.87.87 0 0 0 .459-.668L10.056.77a.87.87 0 0 1 1.47-.522Z"/></symbol><symbol class="bcvip-svg-icon-wrap" viewBox="0 0 58 58" style="enable-background:new 0 0 58 58" xml:space="preserve" id="ico-vip" xmlns="http://www.w3.org/2000/svg"><path class="bcvip-svg-icon bcvip-svg-icon-wings" d="M28.1 42.7s-.8-.1-1.5-.2c-.4-.1-.8-.1-1.1-.1-.3-.1-.5-.1-.5-.1-.2-2.9-1.2-4.3-2-5.1-.5-.4-1.8-1-1.8-1 0 .9-.1 2 .2 3.1.3 1 1 2.1 2.4 2.7-.1.1-4.2-1.4-4.1-1.6.3-1.4.3-2.5.1-3.4-.1-.9-.3-1.5-.6-2s-1.3-1.4-1.3-1.4c-.3.8-.7 1.8-.8 2.9-.1.6.1 1.1.3 1.7.2.5.6 1.2 1.2 1.6 0 0-1-.6-1.9-1.3-.5-.3-.9-.7-1.2-1L15 37c1.3-2.5 1.8-4.2 1-6.4-.2-.3-.3-.4-.3-.4-1.1 1.2-3 3.2-1.5 6 0 0-.7-.9-1.3-1.8-.3-.4-.5-1-.7-1.3l-.3-.6c2.1-1.9 3-3.2 3.1-4.3.2-1.1-.1-2.1-.1-2.1-1.5.9-4 2.2-3.5 5.3l-.2-.6c-.1-.4-.2-.9-.4-1.5-.2-1.1-.3-2.2-.3-2.2 2.7-1 3.8-2.3 4.3-3.4s.4-2 .4-2c-1.7.5-4.4 1.1-4.8 4.1 0 0 0-1.1.1-2.2s.3-2.2.3-2.2c2.9-.3 4.3-1.2 5-1.9.4-.4.9-1.5.9-1.5-.9-.2-1.9-.3-3-.1-1.1.2-2.1.9-2.7 2.3 0 0 0-.2.1-.5s.2-.6.3-1c.3-.7.5-1.4.5-1.4.6-.2 1.4-.6 2.1-1.3.7-.7 1-1.8 1.7-3.9-2.4-.2-3.9 1.2-4.4 2.3-.6 1.2-.3 2.2-.1 2.7 0 0-.3.7-.6 1.5-.1.4-.2.8-.3 1.1-.1.3-.1.5-.1.5.2-1.6-.1-2.9-.5-4.1-.4-1.2-.9-2.3-1.1-3.4 0 0-.3.3-.7.9-.3.6-.7 1.4-.9 2.3-.3 1.8.4 4.1 3 5.3 0 0-.2 1.2-.3 2.3-.1 1.2 0 2.4 0 2.4-.5-3.2-2.6-4.7-3.9-6.4 0 0-.6 1.5-.4 3.2.2 1.8 1.4 3.8 4.3 4.3 0 0 .1 1.2.3 2.3.2 1.2.6 2.3.6 2.3-1.4-2.9-3.7-3.9-5.5-5.2 0 0-.2 1.5.5 3.2.7 1.6 2.4 3.5 5.4 3 0 0 .1.3.3.7.2.4.4 1 .8 1.4.7 1 1.4 1.9 1.4 1.9-2.3-2.2-4.9-2.3-7-3.1 0 0 .1.4.4 1 .3.6.7 1.4 1.3 2.1 1.4 1.3 3.6 2.3 6.2.8l.5.5c.3.3.8.7 1.3 1.1.5.4 1 .7 1.4 1 .3.2.6.3.6.4-.8-.2-1.4-.5-2.1-.6-.7-.1-1.4 0-1.9-.1-1.2 0-2.4.3-3.5.3 0 0 .2.3.7.8.5.4 1.1 1.1 1.9 1.4.9.4 1.9.6 2.9.5 1.1-.2 2.1-.7 3.1-1.8-.1.1 3.5 1.5 4.3 1.6h-2.1c-.7.1-1.3.3-1.9.5-1.2.4-2.2 1-3.2 1.4 0 0 .3.2.8.5s1.3.6 2.2.7c1.8.3 4-.3 5.3-2.9 0 0 .2 0 .5.1.3 0 .7.1 1.1.1l1.6.2c.2 0 .4-.2.4-.4.2.2 0 0-.2 0zm1.8 0s.8-.1 1.5-.2c.4-.1.8-.1 1.1-.1.3-.1.5-.1.5-.1.2-2.9 1.2-4.3 2-5.1.5-.4 1.8-1 1.8-1 0 .9.1 2-.2 3.1-.3 1-1 2.1-2.4 2.7 0 .1 4.2-1.4 4.1-1.6-.3-1.4-.3-2.5-.1-3.4.1-.9.3-1.5.6-2s1.3-1.4 1.3-1.4c.3.8.7 1.8.7 2.9.1.6-.1 1.1-.3 1.7-.2.5-.6 1.2-1.2 1.6 0 0 1-.6 1.9-1.3.5-.3.9-.7 1.2-1l.5-.5c-1.3-2.5-1.8-4.2-1-6.4.2-.3.3-.4.3-.4 1.1 1.2 3 3.2 1.5 6 0 0 .7-.9 1.3-1.8.3-.4.5-1 .7-1.3l.3-.6c-2.1-1.9-3-3.2-3.2-4.3-.2-1.1.1-2.1.1-2.1 1.5.9 4 2.2 3.5 5.3l.2-.6c.1-.4.2-.9.4-1.5.2-1.1.3-2.2.3-2.2-2.7-1-3.8-2.3-4.3-3.4s-.5-2-.5-2c1.7.5 4.4 1.1 4.8 4.1 0 0 0-1.1-.1-2.2s-.3-2.2-.3-2.2c-2.9-.3-4.2-1.2-5-1.9-.4-.4-.9-1.5-.9-1.5.9-.2 1.9-.3 3-.1 1 .2 2.1.9 2.7 2.3 0 0 0-.2-.1-.5s-.2-.6-.3-1c-.3-.7-.5-1.4-.5-1.4-.6-.2-1.4-.6-2.1-1.3-.7-.7-1-1.8-1.7-3.9 2.4-.2 3.9 1.2 4.4 2.3.6 1.2.3 2.2.1 2.7 0 0 .3.7.6 1.5.1.4.2.8.3 1.1.1.3.1.5.1.5-.2-1.6.1-2.9.5-4.1.4-1.2.9-2.3 1.1-3.4 0 0 .3.3.7.9.3.6.7 1.4.9 2.3.4 1.9-.3 4.2-2.9 5.4 0 0 .2 1.2.3 2.3.1 1.2 0 2.4 0 2.4.5-3.2 2.6-4.7 3.9-6.4 0 0 .6 1.5.4 3.2-.2 1.8-1.4 3.8-4.3 4.3 0 0-.1 1.2-.3 2.3-.2 1.2-.6 2.3-.6 2.3 1.4-2.9 3.7-3.9 5.5-5.2 0 0 .2 1.5-.5 3.2-.7 1.6-2.4 3.5-5.4 3 0 0-.1.3-.3.7-.2.4-.4 1-.8 1.4-.7 1-1.4 1.9-1.4 1.9 2.3-2.2 4.9-2.3 7-3.1 0 0-.1.4-.4 1-.3.6-.7 1.4-1.3 2.1-1.4 1.3-3.6 2.3-6.2.8l-.5.5c-.3.3-.8.7-1.3 1.1-.5.4-1 .7-1.4 1-.3.2-.6.3-.6.4.8-.2 1.4-.5 2.1-.6.7-.1 1.4 0 2-.1 1.2 0 2.4.3 3.5.3 0 0-.2.3-.7.8-.5.4-1.1 1.1-1.9 1.4-.9.4-1.9.6-2.9.5-1.1-.2-2.1-.7-3.1-1.8.1.1-3.5 1.5-4.3 1.6h2.1c.7.1 1.3.3 1.9.5 1.2.4 2.2 1 3.2 1.4 0 0-.3.2-.8.5s-1.3.6-2.2.7c-1.8.3-4-.3-5.3-2.9 0 0-.2 0-.5.1-.3 0-.7.1-1.1.1l-1.6.2c-.2 0-.4-.2-.4-.4-.1.1.1-.1.3-.1z"/><path class="bcvip-svg-icon bcvip-svg-icon-emblem" d="M29 12.7c-.1 0-.2 0-.3.1-1.9 1-7.1 3.2-9.4 4.1-.7.3-.8.4-.8.6-.1 2.5-.3 8.6 1.2 12.3 2 4.7 7.5 7 9.1 7.6h.4c1.6-.6 7.1-2.9 9-7.6 1.5-3.7 1.4-9.8 1.2-12.3 0-.2-.1-.4-.8-.6-2.2-.9-7.5-3-9.3-4.1-.1-.1-.2-.1-.3-.1z"/></symbol><symbol viewBox="0 0 106 106" xml:space="preserve" id="ico-weapon-crackshot" xmlns="http://www.w3.org/2000/svg"><path class="bdst0" d="m97.3 9.6-3.1-3.1-3.6 2-36.2 31.7h-.8l-1.4-1.6 1.4-1.2 4.2-2 3.7-2.8-4.9-5.6-3.6 2.8-3.8 5.3-.4-.5-1.9 1.6.4.5-9.8 8.3-.5-.6-1.9 1.6.5.6-6.6 3.3-1.8 1.8 5.2 5.7 2.1-1.8 4-5.6 1.5 1.8-.5 1.6-1.1-.8-1.6 1.2.6.9-1.9 1.7 2.9 3.2-3.4 6.2-3.9.4-17 14 2.4 2.1-1.5 1.5-2.3-1.9-4.1 3.9 16.6 13.8 3.3-4.2-2.3-1.9 1.2-1.3 1.5 1.3L41 75.4l6 2.4 4-4-5.7-6-.4-2.8 3.3-4.3 2.3 2.4h6.3l3.7-3.2 1-5.7-3.2-3.6 22-19-3.1-4 16.9-14.1 3.2-3.9zM18.1 83.7l3 2.7-1.4 1.3-3.2-2.7 1.6-1.3zm6.2 7.9-2.4-2 1.3-1.3 2.3 2-1.2 1.3zm17.3-42-1-1.1 9.8-8.2 1.1 1.2-9.9 8.1zm17.3 5.6-.4 3.5-2.5 2.4-4.6.3-1.9-2.1.7-.9 1.3 1.4h3.4l.9-.8-2.8-.7-1.4-1.7.2-.3 4.6-4 2.5 2.9z"/></symbol><symbol viewBox="0 0 106 106" xml:space="preserve" id="ico-weapon-ranger" xmlns="http://www.w3.org/2000/svg"><path class="best0" d="m76.8 32.6-.1-2.2 22.5-19.3-3.3-3.3-11.4 9.6-4.7-1.3-7.6 6.5-2.2-1-25.7 21.8-3.6-3.5.9-.7 6.5-3.9 2.7.2 1.2-1.1s-1.8-3.4-6.9-8l-1.2 1.3v2.1l-4.6 5.8-8.3 8-3.9 1.7-13.9 11.1-2.9.9s1 2.1 2.4 3.6c2 2 4 3.2 3.7 3l.8-2.6 13.1-11.7 2.5-3.1.2-.2 3.5 3.8-12.4 10.6 1.7 8.9-19 16.5L17 98.2l16.9-17 3.4 7.5 11.3-6.3-5-9.4 9.4-9.8-2.2-3.8 1.5.8 6.6 5.5 8.7-10.8c-7.7-4.6-9.6-8-9.6-8l5.2-2 13.6-12.3zm1.2-12 1.8.6-4.6 4-1-1.1 3.8-3.5zM17.5 89.1l-3.5-5 2.5-2.2 3.8 4.4-2.8 2.8zm8.1-4.2-4.4-7.3L29 71l3.5 7.3-6.9 6.6zm23.9-22.1-7.3 7.6-2.5-4.6 4.9-2.3-.3-2c-1.5.6-2.5-.1-3.2-.7l4.9-3.7.1.1 3.4 5.6z"/></symbol><symbol viewBox="0 0 106 106" xml:space="preserve" id="ico-weapon-rpegg" xmlns="http://www.w3.org/2000/svg"><path class="bfst0" d="m78.1 48.5-5.1-.1.1-1.7 6.2-5.1 1.4-3.2.9 1.1 19.2-13.1s-.9-3.1-3.7-7l.2-1.8c.2-1.2-.7-2.3-1.9-2.4l-1.9-.2c-1.7-1.7-3.7-3.4-6.2-5L70.9 26.6l1.3 1.5-1.5.5-5.5-2.6-4.9 4.1.8 4.4-4.7 3.8-4-4.6.1-.1 1.4.3 7.4-6.9.6.7 4.2-3.4-5.3-6.3-4.2 3.4.4.6-7.8 6v1.5l-12.4 8.6 5.4 6.2 5.7-6 3.4 4.7-1.6-.4-3.7 2.8 1 1.3-22.3 19-1.4-.5-3.5 2.8.2 1.3-8.8 5.2-2.2-.3-3.9 3.5s3.4 11.5 14.7 18.2l4.4-3.5.3-2.2 6-7.5.6-.5 1.3.4 3.2-2.8-.1-1.4 2.9-2.5 11.1 11.6 7.1-6.2-10-12.6 9.5-8.2 8.3.2.2.3-2.1 2.1 5.1 6.8 1.8-1.7 5.8 9 6.5-6.1-4.2-10.8 5.2-5.7-4.6-6.1zm-1.4 2.6 2.5 3.6-3.2 3.4-2-2.5 2.5-1.9-.6-.7-3.1-.1.1-1.9 3.8.1zM63.2 31.2l2.4-2 1.4.7-.3.1-3.3 2.6-.2-1.4z"/></symbol><symbol viewBox="0 0 106 106" xml:space="preserve" id="ico-weapon-scrambler" xmlns="http://www.w3.org/2000/svg"><path class="bgst0" d="M94.5 15.3c-.3-.6-.9-1.5-1.8-2.6-.9-1-1.6-1.8-2.2-2.3-.5-.4-1.1-.4-1.6-.1l-3.7 3-2.2-.6-3.1 2.2.5 2.2L46 44.6c-.2.2-.4.4-.7.6l-2.6-2.5-1.7 1.5 2.5 3c-5.2 6.5-10 17.3-10 17.3l-3.3.2L11.4 83l11.3 12.9L41 67.7l2.8 1.5.6-.2c7.9-2.4 9.5-7.5 9.5-7.7l.2-.7-3.9-5.1 10.5-6.8L85.1 28c.8-.7.9-1.8.3-2.7l-.7-1 9.4-7.5c.5-.3.7-1 .4-1.5zM44.1 66.1l-1.5-.8 2.5-3.8h3l.9-1-2.1-1.5 1.2-1.4 2.7 3.5c-.5 1.1-2.3 3.5-6.7 5z"/></symbol><symbol viewBox="0 0 106 106" xml:space="preserve" id="ico-weapon-soldier" xmlns="http://www.w3.org/2000/svg"><path class="bhst0" d="m61.7 51.4.4-1.3 22.4-19.7-.2-1.8 14.6-12.7-3.3-3.3-4.3 3.6C86.7 13.9 83 8.7 83 8.7l-1.9 1.7c3.5 4 5.2 7.5 6.1 9.5l-.9.7-6.1-3-3.4 2.8-1.6-1-11.5 9.5.2 2.2-.5.4-3.6-1.1-5.3 4.8-1.3-.8-1.2 1.2 2.6 3.1-28 23.2.4 6.5-2.7 4.5-3.1-.2L7.1 85l10.5 12.1 14.8-23.3 1.3-.5 8.7 24.1 10.8-9.1-6.4-13.9 7.1-6.7-3-5c2.8 2.7 18.2 16.9 38.8 15.6L91 63.1s-17.8 1.3-29.3-11.7zm24.9-36.3c.2-.2.5-.2.8 0l1.6 1.2c.3.2.3.7 0 1l-.6.5c-.3.2-.7.2-.9-.2l-.9-1.7c-.3-.3-.2-.7 0-.8zM45.5 71.6 44 68.2l4.2-2.1-.5-.9-2.7-.7.9-2 1.4-.3 2.9 4.9-4.7 4.5z"/></symbol><symbol viewBox="0 0 106 106" xml:space="preserve" id="ico-weapon-trihard" xmlns="http://www.w3.org/2000/svg"><path d="m94.3 7.4-2.8.5-1 3-12.1 11.8-1.1-.9-5 4.5 3.8 4.1.6 2.9-2 1.4-5.4-6.5-9-1-12 10.3-.5-.5 2-1.7-3.5-4.3-2.1 2-.7-.7-5.1 4.9.7.7-2 1.8 3.1 3.7 2.4-2 .6.6-6.2 5.2 1.8 1.9 7.9-6.8h1l1.1 1.2.2.7-.3.3.3 2.3-2 1.3-1.2-1.1-28.2 21.2 2.2 2.7-12.1 9.4v4.2l9.4 8.6 1.7-.6 6.2 6.1 5.2-4.6.6-14h2.9l1.5-1.4s2.9 3.2 6.7 6.1c3.8 2.9 10.3 8.1 10.3 8.1L58.3 81v-2.4l-2.7-.6s-8-4.8-11.6-9.1l1.1-1.1-1.1-2.6 7.4-6.5L59 70.5l3.4 1.1 9.5-8-5.7-15.9 1.9-1.4 1.5 1.1 2.3-1.8-1-1.9 1-.8 11.7 10.9 2.7-2.5L77.4 38l4.3-3.3-.7-6.2-.8-1.3.3-1.5L95 15.3l2.8-.5.5-2.9-4-4.5zm-37 31.2-4.3.6.8 2.3-1.8.5-1.1-.3-.9-1.3v-.9l11-9.6 2.3 1.5-.4 2.3-3.2-.1.9 2.2-4.2.4.9 2.4zm11.1 23.6-4.6 4.4-4.6-8 .8-2.4.9-.1-.1-1.6-1.7-2.5 4.3-3.8 5 14z"/></symbol><symbol viewBox="0 0 106 106" xml:space="preserve" id="ico-weapon-whipper" xmlns="http://www.w3.org/2000/svg"><path class="bjst0" d="m98 16.8-2.9-3.4c-.4-.4-1.1-.5-1.5-.1L90.4 16c-.3.3-.5.7-.3 1.1l-6.4 5.6-5.4-5.7-2-1-4-3.9-.7.5-.5 1.1-1.7-2.1-1 .8 1.7 2.1-1.2.2-1.8 1.4.2 1.1-1.1.8-1.1-.4-1.7 1.3.2 1.2-.9.9-1.1-.4-1.7 1.4.2 1.2-1 .8-1.2-.4-1.6 1.3.2 1.3-1.1.8-1.3-.4-1.7 1.4v1.3l-2.8-3.5-1.8 1.5 3.7 4.5-.8 1.2 1.8 8.1L7.8 78l16 16.3H26l18.4-16 10.5-.5 9.5-5.5 5.2-7.1v-7.4l9-6.2 2.1 4.1 5.3-4.2v-6.9l-3.7-6.2 3.7-3.2 3.9 4.2 4.1-3.3-4.7-6.1h-4l.8-2.2 7.6-6.6c.3.1.7 0 1-.2l3.2-2.7c.4-.4.5-1.1.1-1.5zM58.6 66.1l-6.2 4.5-6.6-7.3 10.6-9c1.5 1.9 4.6 4.9 4.6 4.9l-2.4 6.9zm-.8-29.5-.6-2.3 14.4-12.1 3 .5-16.8 13.9zM74.4 50l-4.1-3.3-.8-3.3 5.5-4.6 4.4 6.2-5 5z"/></symbol><symbol viewBox="0 0 73.59 154.88" class="bkicon-spatula" id="ico_spatula"><path d="M63.08 0H10.51C4.73 0 0 5.15 0 11.44V57.2c0 6.29 4.73 11.44 10.51 11.44h21.03v21.92c0 2.59-.95 5.07-2.63 6.9s-2.63 4.31-2.63 6.9v40.76c0 5.39 4.02 9.76 8.97 9.76h3.09c4.95 0 8.97-4.37 8.97-9.76v-40.76c0-2.59-.95-5.07-2.63-6.9s-2.63-4.31-2.63-6.9V68.64h21.03c5.78 0 10.51-5.15 10.51-11.44V11.44C73.59 5.15 68.86 0 63.08 0ZM42.05 17.16v34.32c0 3.16-2.35 5.72-5.26 5.72-2.9 0-5.26-2.56-5.26-5.72V17.16c0-3.16 2.35-5.72 5.26-5.72 2.9 0 5.26 2.56 5.26 5.72ZM57.82 57.2c-2.9 0-5.26-2.56-5.26-5.72V17.16c0-3.16 2.35-5.72 5.26-5.72 2.9 0 5.26 2.56 5.26 5.72v34.32c0 3.16-2.35 5.72-5.26 5.72ZM21.03 17.16v34.32c0 3.16-2.35 5.72-5.26 5.72-2.9 0-5.26-2.56-5.26-5.72V17.16c0-3.16 2.35-5.72 5.26-5.72 2.9 0 5.26 2.56 5.26 5.72Z" style="stroke-width:0" data-name="Layer 1"/></symbol><symbol viewBox="0 0 21.95 19.37" id="ico_stampArrow" xmlns="http://www.w3.org/2000/svg"><path d="M21.69 10.34 11.61.26a.9.9 0 0 0-1.27 0L.26 10.34c-.57.57-.16 1.53.63 1.53h4.08v6.6c0 .5.4.9.9.9h10.19c.5 0 .9-.4.9-.9v-6.6h4.08c.8 0 1.2-.97.63-1.53Z" style="stroke-width:0" data-name="Layer 1"/></symbol><symbol viewBox="0 0 38.919 34.476" id="ico_watchAd" xmlns="http://www.w3.org/2000/svg"><path d="M0 12.44v17.55a4.487 4.487 0 0 0 4.487 4.486h29.945a4.487 4.487 0 0 0 4.487-4.487V12.44H0Zm25.075 11.533-7.18 4.788a1.313 1.313 0 0 1-2.042-1.093v-9.575A1.313 1.313 0 0 1 17.895 17l7.18 4.788c.78.52.78 1.666 0 2.185ZM5.933 9.774h6.368L22.075 0h-6.368L5.933 9.774zM34.316 0h-6.368l-9.774 9.774h6.368L34.316 0zM9.834 0H4.487A4.487 4.487 0 0 0 0 4.487v5.287h.06L9.834 0Zm20.581 9.774h8.504V4.487c0-.914-.275-1.763-.744-2.473l-7.76 7.76Z" style="fill:#fff"/></symbol></svg>		<!-- Ads -->
		<div id="gameAdContainer" class="hideme">
</div>

<div id="shellshockers_titlescreen"></div>
<div id="shellshockers_chicken_nugget_banner"></div>
<div id="shellshockers_respawn_banner-sh"></div>
<div id="shellshockers_respawn_banner_2-sh"></div>
<div id="shellshockers_respawn_banner_3-sh"></div>
<div id="shellshockers_respawn_banner"></div>
<div id="shellshockers_respawn_banner-new"></div>
<div id="ShellShockers_LoadingScreen_HouseAds"></div>
<div id="shellshock-io_728x90_HP"></div>

<div id="videoAdContainer">
    <div id="preroll"></div>
</div>

<!-- <div class="video_ad_wrapper">
    <video id="asc_video_ad" class="video-js vjs-default-skin" controls preload="auto" width="640" height="360" muted="true" style="display: none;">
        <source src="video/tiny.mp4" type="video/mp4" />
    </video>
</div> -->
		<div id="ss_background"></div>

		<!-- Instantiate the Vue instance -->
		<div id="app" :class="[currentLanguageCode, appClassObj, appClassScreen, isPhotoBooth]"> <!-- vue instance div: all vue-controlled elements MUST be inside this tag -->
<!-- <asc-video-player id="mainVideoPlayer" ref="mainVideoPlayer" adTagUrl="adTagUrl"></asc-video-player> -->
    <div class="firebaseID">firebase ID: {{ firebaseId }}, maskedEmail: {{ maskedEmail }} isAnonymous: {{ isAnonymous }}, isEmailVerified: {{ isEmailVerified }}</div>
    <!-- Canvas -->
	<div ref="gameCanvas" class="canvas-wrapper gameCanvas">
		<canvas id="canvas" ref="canvas"></canvas>
	</div>
    <!-- Overlays -->
    <light-overlay id="lightOverlay" ref="lightOverlay"></light-overlay>
    <dark-overlay ref="darkOverlay"></dark-overlay>
    <spinner-overlay id="spinnerOverlay" ref="spinnerOverlay" :loc="loc" :hide-ads="hideAds" :ad-unit="displayAd.adUnit.spinner" :account-date="accountCreated"></spinner-overlay>
	<div ref="abTestContainer" class="ab-test-inventory-flow hideme popup_window popup_sm roundme_md centered">
		<img ref="abTestArrow" class="ab-test-arrow" src="/img/kotc/kotc-arrow.svg" alt="">
		<p v-html="abTestText"></p>
	</div>

    <!-- GDPR -->
    <gdpr id="gdpr" ref="gdpr" :loc="loc"></gdpr>
	<div ref="headerAdContainer"></div>
	<account-panel v-show="ui.showHomeEquipUi" id="account_panel" ref="accountPanelHome" :loc="loc" :selected-language-code="currentLanguageCode" :eggs="eggs" :languages="languages" :current-lang-options="locLanguage" :show-corner-buttons="ui.showCornerButtons" :is-private-game="extern.isPrivateGame" :show-bottom="true" :photo-url="photoUrl" :is-anonymous="isAnonymous" :is-of-age="isOfAge" :show-targeted-ads="showTargetedAds" :current-screen="showScreen" :screens="screens" :is-egg-store-sale="isEggStoreSaleItem" :is-subscriber="isSubscriber" @sign-in-clicked="onSignInClicked" @sign-out-clicked="onSignOutClicked" :is-twitch="twitchLinked"></account-panel>
	<div id="main-content" class="main-content display-grid height-100vh">
		<photo-booth-ui id="photoBooth" ref="photoBooth" v-show="!ui.showHomeEquipUi" :loc="loc"  :player-name="playerName" :item-type-change="ui.photoBooth.type" @bg-change-color="onPhotoboothBgColorChange" @bg-change-image="onPhotoBoothBgImageChange" @hide-ui="onPhotoBoothHideUi"></photo-booth-ui>
		<aside ref="mainAside" v-show="showScreen !== screens.photoBooth" class="main-aside">
			<main-sidebar ref="mainMenu" v-show="ui.showHomeEquipUi" :loc="loc" :player-name="playerName" :menu-items="ui.mainMenu" :current-screen="showScreen" :screens="screens" :mode="equipMode" :current-mode="currentEquipMode" :is-game-paused="game.isPaused" :in-game="game.on" :picked-game-type="currentGameType" @previous-screen="setPreviousScreen"></main-sidebar>
			<house-ad v-show="showScreen !== screens.game && ui.showHomeEquipUi" :loc="loc" :upgrade-name="upgradeName" :is-upgraded="isUpgraded" :is-subscriber="isSubscriber" :has-mobile-reward="hasMobileReward" :crazy-games-active="ui.crazyGames" :is-poki="isPoki" :chw-count="chw.winnerCounter" :chw-ready="showAdBlockerVideoAd" :chw-limit-reached="chw.limitReached" :ad="ui.houseAds.small" :in-game="game.on" @chw-video-request="showNuggyPopup"></house-ad>
			<div id="chw-home">
				<chw ref="chwHomeScreen" :loc="loc" :chw="chw" :firebase-id="firebaseId" :current-screen="showScreen" :screens="screens" :ui="ui"></chw>
			</div>
			<!-- .chw-timer -->
		</aside>
		<!-- .chw-home-timer -->
		<main id="mainScreens">
			<div id="paper_doll_container" class="paper-doll-click-container centered z-index-1" v-show="showScreen === screens.home || showScreen === screens.equip"></div>
			<home-screen id="home_screen" ref="homeScreen" v-show="(showScreen === screens.home || showScreen === screens.profile)"></home-screen>
			<equip-screen id="equip_screen" class="height-100vh" ref="equipScreen" v-show="showEquipScreens" @photo-booth-type-id="photoBoothTypeChange"></equip-screen>
			<game-screen id="game_screen" ref="gameScreen" v-show="(showScreen === screens.game)" :kname="killName" :kdname="killedName"></game-screen>
		</main>
	</div>
	<div id="gameDescription" v-show="(showScreen === screens.home)">
		<section class="social-icons ss_marginright">
			<social-panel ref="socialIconPanel" id="social_panel" :loc="loc" :is-poki="isPoki" :use-social="ui.socialMedia.footer" :social-media="ui.socialMedia.selected"></social-panel>
		</section>
		<section class="game-info">
			<h1 class="text-center">{{ loc.home_desc_about }}</h1>
			<p class="text-center">{{ loc.home_desc_pick }}
			<svg class="eggIcon"><use xlink:href="#icon-egg"></use></svg>
			{{ loc.home_desc_loadout }}
			<svg class="eggIcon"><use xlink:href="#icon-egg"></use></svg>
			{{ loc.home_desc_madeof }}</p>
			<section class="text-center">
				<p>{{ loc.home_blocked_start }} geometry.monster {{ loc.home_blocked_end }}</p>
			</section>
			<div class="display-grid grid-column-2-eq gap-1 ">
				<section>
					<p>{{ loc.home_desc_p1 }}</p>
					<p>
						<img v-lazyload :data-src="ui.lazyImages.homeEgg1" class="lazy-load" style="width: 350px; float: left; margin-right: 1em; shape-outside: polygon(0% 0%, 100% 0%, 100% 41%, 84% 48%, 80% 63%, 59% 74%, 46% 100%, 0% 99%);">{{ loc.home_desc_p2 }}
					</p>
				</section>
				<section>
					<p>
						<img v-lazyload :data-src="ui.lazyImages.homeEgg2" class="lazy-load" style="float: right; margin-left: 1em; margin-top: 1em; shape-outside: polygon(1% 0%, 100% 1%, 100% 99%, 50% 100%, 28% 86%, 16% 68%, 14% 51%, 0 35%);">
						{{ loc.home_desc_p3 }} <br /><br />
						{{ loc.home_desc_p4 }}
					</p>
				</section>
			</div>
			<section>
				<header>
					<h2 class="text-center">{{ loc.home_game_mode_title }}</h2>
				</header>
				<ul class="display-grid grid-column-2-eq gap-1 ">
					<li v-html="loc.home_game_mode_content_li_1"></li>
					<li v-html="loc.home_game_mode_content_li_2"></li>
					<li v-html="loc.home_game_mode_content_li_3"></li>
					<li v-html="loc.home_game_mode_content_li_4"></li>
				</ul>
			</section>
	
			<h2 class="text-center">{{ loc.home_desc_controls }}</h2>
			<p class="text-center">{{ loc.home_desc_standard }}</p>
	
			<ul class="display-grid grid-column-2-eq" style="min-width: 25em;max-width: 35em;margin:0 auto">
				<li> {{ loc.home_desc_control1 }}</li>
				<li> {{ loc.home_desc_control2 }}</li>
				<li> {{ loc.home_desc_control3 }}</li>
				<li> {{ loc.home_desc_control4 }}</li>
				<li> {{ loc.home_desc_control5 }}</li>
				<li> {{ loc.home_desc_control6 }}</li>
				<li> {{ loc.home_desc_control7 }}</li>
				<li> {{ loc.home_desc_control8 }}</li>
				<li> {{ loc.home_desc_control9 }} </li>
			</ul>
	
			<p class="text-center">
				<button class="ss_button btn_lg btn_blue bevel_blue" @click="openUnblocked">{{ loc.home_unblocked_text }}</button>
			</p>
			<p v-html="footerLinksFormat"></p>
	
			<p align="center"><button class="ss_button btn_yolk bevel_yolk" @click="vueApp.scrollToTop()">{{ loc.home_backtotop }}</button></p>
		</section>

	</div>
	<!-- #gameDescription -->

    <!-- Popup: Settings -->
    <large-popup id="settingsPopup" ref="settingsPopup" @popup-closed="onSharedPopupClosed" @popup-opened="onSettingsPopupOpened" @popup-x="onSettingsX">
        <template slot="content">
        <settings id="settings" ref="settings" :loc="loc" :settings-ui="settingsUi" :languages="languages" :current-language-code="currentLanguageCode" :show-privacy-options="showPrivacyOptions" @privacy-options-opened="onPrivacyOptionsOpened" :is-from-eu="showPrivacyOptions" :controller-id="controllerId" :controller-type="controllerType" :lang-option="locLanguage" :is-vip="(isSubscriber || contentCreator)" :region-list="regionList" :current-region-id="currentRegionId"></settings>
        </template>
    </large-popup>

    <!-- Popup: Private Game Options -->
	<game-options-popup ref="gameOptionsPopup" id="gameOptionsPopup" :loc="loc" :game-options-popup="gameOptionsPopup"></game-options-popup>

    <!-- Popup: Privacy Options -->
    <small-popup id="privacyPopup" ref="privacyPopup" hide-cancel="true" @popup-closed="onSharedPopupClosed">
        <template slot="header">{{ loc.p_settings_privacy }}</template>
        <template slot="content">
            <label class="ss_checkbox label"> {{ loc.p_settings_of_age }}
                <input id="ofAgeCheck" type="checkbox" v-model="isOfAge" @change="ofAgeChanged($event)">
                <span class="checkmark"></span>
            </label>

            <label class="ss_checkbox label"> {{ loc.p_settings_target_ads }}
                <input id="targetedAdsCheck" type="checkbox" v-model="showTargetedAds" @change="targetedAdsChanged($event)">
                <span class="checkmark"></span>
            </label>
            <!--
            <input id="ofAgeCheck" type="checkbox" v-model="isOfAge" @change="ofAgeChanged($event)">&nbsp;{{ loc.p_settings_of_age }}<br>
            <input id="targetedAdsCheck" type="checkbox" v-model="showTargetedAds" @change="targetedAdsChanged($event)">&nbsp;<span id="targetedAdsText">{{ loc.p_settings_target_ads }}</span>
            -->
        </template>
        <template slot="confirm">{{ loc.ok }}</template>
    </small-popup>

    <!-- Popup: Help & Feedback -->
    <large-popup id="helpPopup" ref="helpPopup" stop-key-capture="true" @popup-closed="onSharedPopupClosed">
        <template slot="content">
			<help id="help" ref="help" :loc="loc" :account-type="accountStatus" :feedback-type="feedbackType" :open-with-type="feedbackSelected" @resetFeedbackType="resetFeedbackType"></help>
        </template>
    </large-popup>

    <!-- Popup: VIP Help & Feedback -->
    <large-popup id="vipPopup" ref="vipPopup" stop-key-capture="true" @popup-closed="onVipHelpClosed">
        <template slot="content">
            <vip-help id="vip-help" ref="vip-help" :loc="loc" :is-vip="isSubscriber"></help>
        </template>
    </large-popup>

    <!-- Popup: Egg Store -->
    <large-popup id="eggStorePopup" ref="eggStorePopup" stop-key-capture="true" @popup-closed="onSharedPopupClosed" :overlay-close="false">
        <template slot="content">
            <subscription-store id="eggStore" ref="eggStore" :loc="loc" :products="eggStoreItems" :sale-event="isSale"></subscription-store>
        </template>
    </large-popup>

    <!-- <img v-if="blackFridayBanner" class="black-friday-banner" style="display: none" src="img/black-friday-banner.jpg" alt="Black Friday Sale"/> -->

    <!-- Popup: VIP store -->
    <large-popup id="subStorePopup" ref="subStorePopup" stop-key-capture="true" @popup-closed="onSharedPopupClosed" :overlay-close="true">
        <template slot="content">
            <subscription-store id="shell-subscriptions" ref="shell-subscriptions" :loc="loc" :subs="subStoreItems"></subscription-store>
        </template>
    </large-popup>

    <!-- Popup: VIP ended -->
    <small-popup id="vipEnded" ref="vipEnded" stop-key-capture="true" @popup-confirm="showSubStorePopup" @popup-closed="onSharedPopupClosed" :overlay-close="true" class="vip">
        <template slot="content">
            <figure>
                <img v-lazyload :data-src="ui.lazyImages.vipEmblem" class="lazy-load" alt="Shell Shockers VIP">
            </figure>
            <div class="vip-ended-popup">
                {{ loc.account_vip_expired }}
            </div>
        </template>
        <template slot="confirm">{{ loc.account_vip_expire_3 }}</template>
        <template slot="cancel">{{ loc.account_vip_expired_2 }}</template>
    </small-popup>

    <!-- Popup: Egg Store single -->
    <large-popup id="popupEggStoreSingle" ref="popupEggStoreSingle" stop-key-capture="true" @popup-closed="onSharedPopupClosed" :overlay-close="false" class="popup-store-single">
        <template slot="content">
            <egg-store-item v-for="item in premiumShopItems" :key="item.sku" :item="item" :loc="loc" :account-set="accountSettled" v-if="eggStorePopupSku && item.sku === eggStorePopupSku"></egg-store-item>
        </template>
    </large-popup>

    <!-- Popup: Unsupported Platform -->
    <large-popup id="unsupportedPlatformPopup" ref="unsupportedPlatformPopup" hide-close="true">
        <template slot="content">
            <h2>{{ loc['unsupported_platform'] }}</h2>
            <div>{{ loc[unsupportedPlatformPopup.contentLocKey] }}</div>
        </template>
    </large-popup>

    <!-- Popup: Missing Features -->
    <large-popup id="missingFeaturesPopup" ref="missingFeaturesPopup" hide-close="true">
        <template slot="content">
            <h2>{{ loc['oh_no'] }}</h2>
            <span>{{ loc['missing_features'] }}</span>
            <ul>
                <li v-for="f in missingFeatures" v-html="f"></li>
            </ul>
            <span>{{ loc['missing_help'] }}</span>
        </template>
    </large-popup>

    <!-- Popup: No Anon -->
    <small-popup id="noAnonPopup" ref="noAnonPopup" @popup-confirm="onNoAnonPopupConfirm" @popup-closed="onSharedPopupClosed">
        <template slot="header">{{ loc.no_anon_title }}</template>
        <template slot="content">
            <div>{{ loc.no_anon_msg1 }}</div>
            <div>{{ loc.no_anon_msg2 }}</div>
        </template>
        <template slot="cancel">{{ loc.cancel }}</template>
        <template slot="confirm">{{ loc.no_anon_signup }}</template>
    </small-popup>

    <!-- Popup: Give Stuff -->
	<give-stuff-popup ref="giveStuffPopup" id="giveStuffPopup" :loc="loc" :give-stuff-popup="giveStuffPopup" :imgs="ui.lazyImages"></give-stuff-popup>

    <!-- Popup: Open URL -->
    <small-popup id="openUrlPopup" ref="openUrlPopup" @popup-confirm="onOpenUrlPopupConfirm" @popup-closed="onSharedPopupClosed">
        <template slot="header">{{ loc[openUrlPopup.titleLocKey] }}</template>
        <template slot="content">
            <!-- content not loc'd (yet) -->
            {{ openUrlPopup.content }}
        </template>
        <template slot="cancel">{{ loc[openUrlPopup.cancelLocKey] }}</template>
        <template slot="confirm">{{ loc[openUrlPopup.confirmLocKey] }}</template>
    </small-popup>

    <!-- Popup: Changelog -->
    <large-popup id="changelogPopup" ref="changelogPopup" @popup-closed="onSharedPopupClosed">
        <template slot="content">
            <h1 id="popup_title nospace" class="roundme_sm">
                {{ loc.changelog_title }}
            </h1>

            <div class="changelog_content roundme_lg">
				<section v-for="(log, idx) in changelog.current">
					<h3>{{ log.version }} - <i><time>{{ log.date }}</time></i></h3>
					<ul>
						<li v-for="data in log.content" v-html="data"></li>
					</ul>
					<hr class="blue">
				</section>
            </div>
			
            <div id="btn_horizontal">
				<button v-if="changelog.showHistoryBtn" @click="showHistoryChangelogPopup" class="ss_button btn_green bevel_green">{{ loc.more }}</button>
                <button @click="hideChangelogPopup" class="ss_button btn_red bevel_red">{{ loc.close }}</button>
            </div>
        </template>
    </large-popup>

    <!-- Popup: Golden Chicken -->
    <large-popup id="goldChickenPopup" ref="goldChickenPopup" :overlay-close="false">
        <template slot="content">
            <gold-chicken-popup id="gold_chicken" ref="gold_chicken" :loc="loc" @close-chw-popup="hideChickenPopup" @open-chw-game="goldChickenPopupOpenChw"></gold-chicken-popup>
        </template>
    </large-popup>

    <!-- Popup: Chicken Nugget -->
    <large-popup id="chicknWinner" ref="chicknWinner" :hide-close="!chwMiniGameComplete" :overlay-close="chwMiniGameComplete" @popup-closed="onChwPopupClosed">
        <template slot="content">
            <chicken-nugget-popup id="chickenNugget" ref="chickenNugget" :key="chw.nuggetReset" :loc="loc" :firebase-id="firebaseId" :reward="chw.reward" :ad-unit="displayAd.adUnit.nugget" :chw="chw" @chw-start-reward="chwDoIncentivized" @chw-mini-game-complete="chwMiniGameCompleted"></chicken-nugget-popup>
			<display-ad id="shellshockers_chicken_nugget_banner_ad" ref="nuggetDisplayAd" class="pauseFiller center_h" :ignore-size="true" :ad-unit="displayAd.adUnit.nugget" ad-size="728x90"></display-ad>
        </template>
    </large-popup>
    
    <!-- Popup: Generic Message -->
    <small-popup id="genericPopup" ref="genericPopup" :popup-model="genericMessagePopup" :hide-cancel="true" @popup-closed="onSharedPopupClosed">
        <template slot="header">{{ loc[genericMessagePopup.titleLocKey] }}</template>
        <template slot="content">{{ loc[genericMessagePopup.contentLocKey] }}</template>
        <template slot="confirm">{{ loc[genericMessagePopup.confirmLocKey] }}</template>
    </small-popup>

    <!-- Popup: Anon warning message -->
    <small-popup v-if="isAnonymous" id="anonWarningPopup" ref="anonWarningPopup" :hide-close="true" :overlay-close="false" @popup-cancel="anonWarningPopupCancel" @popup-confirm="anonWarningPopupConfrim">
        <template slot="header"><img src="img/svg/ico_goldenEgg.svg" class="egg_icon" />{{ loc.account_anon_warn_popup_title }}! <img src="img/svg/ico_goldenEgg.svg" class="egg_icon" /></template>
        <template slot="content">
            <p v-html="anonPopupContent"></p>
        </template>
        <template slot="cancel">{{ loc.pwa_no_thanks }}</template>
        <template slot="confirm">{{ loc.sign_in }}</template>
    </small-popup>
    
    <!-- Popup: Need More eggs popup -->
    <small-popup id="needMoreEggsPopup" ref="needMoreEggsPopup" @popup-confirm="showEggStorePopup">
        <template slot="header">{{ loc.p_buy_isf_title }}!</template>
        <template slot="content">
            <p>{{ loc.p_buy_isf_content }}.</p>
        </template>
        <template slot="cancel">{{ loc.p_buy_item_cancel }}</template>
        <template slot="confirm">{{ loc.account_title_eggshop }}</template>
    </small-popup>
    
    <!-- Popup: Firebase Sign In -->
    <large-popup id="firebaseSignInPopup" ref="firebaseSignInPopup" :overlay-close="false">
        <template slot="content">
            <h1 class="nospace">{{ loc.sign_in }}</h1>
            <div id="firebaseui-auth-container"></div>
            <div id="btn_horizontal" class="f_center">
                <button @click="onSignInCancelClicked()" class="ss_button btn_red bevel_red btn_sm">{{ loc.cancel }}</button>
            </div>
        </template>
    </large-popup>

    <small-popup ref="adBlockerPopup" id="adBlockerPopup" :overlay-close="false" hide-confirm="true" hide-cancel="true" hide-close="true">
        <template slot="header">
        We've detected ad blocker!
        </template>
        <template slot="content">
            <p>To <i>avoid</i> this message please turn <i>off</i> ad blocker.</p>
            <h4>Please wait</h4>
            <h3>{{adBlockerCountDown}}</h3>
        </template>   
    </small-popup>

    <!-- Popup: PWA -->
    <small-popup id="pwaPopup" class="pwa-popup" ref="pwaPopup" hide-confirm="true" @popup-closed="onSharedPopupClosed">
        <!-- <template slot="header">{{ loc.p_settings_privacy }}</template> -->
        <template slot="content">
            <p>{{loc.pwa_desc_one}}</p>
            <p>{{loc.pwa_desc_two}}</p>
            <button @click="pwaBtnClick" class="ss_button btn_big btn_green bevel_green btn_height_auto btn-pwa-download">
                <div class="pwa-btn-img-box roundme_lg bg-darkgreen">
                    <img src="favicon192.png" alt="Egg yolk">
                    <i class="fas fa-share" aria-hidden="true"></i>
                </div>
                {{loc.pwa_btn_line_one}}<br/>{{loc.pwa_btn_line_two}}
            </button>
        </template>
        <template slot="cancel">{{loc.pwa_no_thanks}}</template>
    </small-popup>

    <large-popup id="adBlockerVideo" ref="adBlockerVideo" @popup-closed="onSharedPopupClosed" :overlay-close="false" hide-confirm="true" hide-cancel="true" hide-close="true">
        <template slot="content">
            <p class="text-center">{{ loc.ad_blocker_big_popup_title }}<br /> <span v-html="loc.ad_blocker_big_popup_desc"></span></p>
			<img v-lazyload :data-src="ui.lazyImages.adBlockPopup" class="lazy-load" alt="Please remove ad blockers" />
            <!-- <house-ad id="house-ad-video-replacement" ref="house-ad-video-replacement" :data="bannerHouseAd" :isshowing="showAdBlockerVideoAd"></house-ad> -->
        </template>
    </large-popup>

    <!-- <large-popup ref="kotcInstrucPopup" id="kotcInstrucPopup" :overlay-close="true" hide-confirm="true" hide-cancel="true">
        <template slot="content">
            <img class="kotc-wordmark" src="img/kotc/kotc-wordmark.svg" alt="">
            <div class="kotc-how-to-play-wrapper box_absolute">
                <h2 class="kotc-how-to-play-title text-center"><span class="roundme_md">{{ loc.home_kotc_popup_how_to }}</span><br />{{ loc.home_play }}!</h2>
                <img src="img/kotc/kotc-arrow.svg" aria-hidden="true">
            </div>
            <div class="display-grid grid-column-2-eq grid-gap-space-lg fullwidth ss_margintop_xxxxl">
                <div class="img-container roundme_lg fullwidth step-one">
                    <div class="fullwidth">
                        <p class="text-center"><span class="sr-only">Step </span>1</p>
                        <h6 class="text-center">{{loc.home_kotc_popup_step_one}}</h6>
                    </div>
                </div>
                <div class="img-container roundme_md fullwidth step-two">
                    <div class="fullwidth">
                        <p class="text-center"><span class="sr-only">Step </span>2</p>
                        <h6 class="text-center">{{loc.home_kotc_popup_step_two}}</h6>
                    </div>
                </div>
            </div>
            <div class="display-grid grid-column-2-eq grid-gap-space-lg roundme_md fullwidth ss_margintop_lg kotc-play-now step-three-wrapper">
                <div class="fullwidth box_relative step-three">
                    <img class="kotc-logo box_absolute" src="img/kotc/kotc-rooster.svg" alt="The King of the Coop Rooster">

                    <div>
                        <p class="text-center"><span class="sr-only">Step </span>3</p>
                        <h6 class="text-center" v-html="loc.home_kotc_popup_step_three"></h6>
                    </div>
                </div>
                <div class="fullwidth f_col f_space_between">
                    <div class="display-grid grid-column-5-eq kotc-crowns">
                    <img aria-hidden="true" src="img/kotc/kotc-crown.svg" alt="Crowns">
                    <img aria-hidden="true" src="img/kotc/kotc-crown.svg" alt="Crowns">
                    <img aria-hidden="true" src="img/kotc/kotc-crown.svg" alt="Crowns">
                    <img aria-hidden="true" src="img/kotc/kotc-crown.svg" alt="Crowns">
                    <img aria-hidden="true" src="img/kotc/kotc-crown.svg" alt="Crowns">
                    </div>
                    <button class="ss_button btn_big btn_green bevel_green fullwidth" @click="onClickPlayKotcNow"><i class="fa fa-play fa-sm"></i> {{ loc.home_play }}</button>
                </div>
            </div>
        </template>   
    </large-popup> -->

	<large-popup ref="notificationPopup" id="notificationPopup" @popup-closed="onSharedPopupClosed" :overlay-close="false" :hide-close="true">
		<template slot="header">Notifications</template>
		<template slot="content">
			<notification-content ref="notifiContent" :notification="ui.notification" :loc="loc" :bonus="ui.bonus.showing" @open-bundle="onOpenBundle" @close-popup="onCloseNotification"></notification-content>
		</template>
	</large-popup>

    <!-- Popup: Banned -->
    <large-popup id="bannedPopup" ref="bannedPopup" hide-close="true">
        <template slot="content">
			<h1>{{ loc['banned_title'] }}</h1>
			<p>{{ loc['banned_msg'] }}</p>
			<p>{{ loc['banned_expire'] }} {{ bannedPopup.expire }}</p>
		</template>
    </large-popup>
<!--
    <small-popup id="openUrlPopup" ref="openUrlPopup" @popup-confirm="onOpenUrlPopupConfirm" @popup-closed="onSharedPopupClosed">
        <template slot="header">{{ loc[openUrlPopup.titleLocKey] }}</template>
        <template slot="content">
            {{ openUrlPopup.content }}
        </template>
        <template slot="cancel">{{ loc[openUrlPopup.cancelLocKey] }}</template>
        <template slot="confirm">{{ loc[openUrlPopup.confirmLocKey] }}</template>
    </small-popup>
-->



	<small-popup id="deleteAccountApprovalPopup" ref="deleteAccountApprovalPopup" @popup-confirm="onAccountDelectionConfirmed">
	<!-- <template slot="header">{{ loc.p_settings_privacy }}</template> -->
		<template slot="content">
			<h1 v-html="loc.feedback_account_deletion_title"></h1>
			<p class="text-center">
				<i class="fas fa-exclamation-triangle fa-2x text_red"></i>
			</p>
			<p v-html="loc.feedback_account_deletion_desc_1"></p>
			<p v-html="loc.feedback_account_deletion_desc_2"></p>
		</template>
		<template slot="cancel">{{loc.cancel}}</template>
		<template slot="confirm">{{loc.feedback_account_delection_confirm}}</template>
	</small-popup>

	<!-- Popup: Leave Game Confirm -->
	<small-popup id="leaveGameConfirmPopup" ref="leaveGameConfirmPopup" :overlay-close="false" :hide-close="true" @popup-confirm="onLeaveGameConfirm" @popup-cancel="onLeaveGameCancel" @popup-opened="sharedIngamePopupOpened" @popup-closed="sharedIngamePopupClosed">
		<template slot="header">{{ loc.leave_game_title }}</template>
		<template slot="content">
			<p>{{ loc.leave_game_text }}</p>
		</template>
		<template slot="cancel">{{ loc.no }}</template>
		<template slot="confirm">{{ loc.yes }}</template>
	</small-popup>

	<small-popup id="fbTransferAccountSignin" ref="fbTransferAccountSignin" :hide-confirm="true" :overlay-close="false" @popup-cancel="onLeaveGameCancel" @popup-opened="sharedIngamePopupOpened" @popup-closed="sharedIngamePopupClosed">
		<!-- <template slot="header">{{ loc.leave_game_title }}</template> -->
		<template slot="content">
			<p>{{ loc.signin_fb_msg}}</p>
		</template>
		<template slot="cancel">{{ loc.close }}</template>
		<!-- <template slot="confirm">{{ loc.yes }}</template> -->
	</small-popup>

	<!-- Popup: Tutorial -->
	<small-popup id="tutorialPopup" ref="tutorialPopup" :hide-confirm="true" :hide-cancel="true" @popup-closed="onTutorialClosed">
			<template slot="header">{{ loc.tutorial_title }}</template>
			<template slot="content">
				<div class="box_relative display-grid grid-template tutorial-labels">
					<span v-for="(item, idx) in ui.tutorialPopup.keys" :key="idx" v-html="loc[item.locKey]" class="box_absolute" :class="item.cls"></span>
					<img src="img/tutorial/ss_tutorial_Keyboard.webp" class="tutorial-keyboard" alt="Tutorial keyboard image">
					<img src="img/tutorial/ss_tutorial_Mouse.webp" class="tutorial-mouse" alt="Tutorial mouse image" >
				</div>
				<div class="tutorial-content display-grid align-items-center center_h">
					<div>
						<img src="img/tutorial/ss_tutorial_EggTarget.webp" class="tutorial-egg" alt="Tutorial egg image" >
					</div>
					<ul class="tutorial-list list-no-style">
						<li class="text-left">{{ loc.tutorial_point_1 }}</li>
						<li class="text-left">{{ loc.tutorial_point_2 }}</li>
						<li class="text-left">{{ loc.tutorial_point_3 }}</li>
					</ul>
				</div>
			</template>
		</small-popup>

		<!-- Popup: xsollaPopup -->
		<small-popup id="xsollaPopup" ref="xsollaPopup" @popup-confirm="xsollaPopupConfrim" @popup-cancel="xsollaPopupCancel">
			<template slot="header">Warning!</template>
			<template slot="content">
				<div>Welcome to our exciting world of egg recipe experiments! Please note that while we're eager to explore the endless possibilities, we cannot guarantee the outcome of all purchases. So, let's embark on this culinary adventure together, but be prepared for the occasional crack in the shell. Happy cooking!</div>
			</template>
			<template slot="cancel">{{ loc.cancel }}</template>
			<template slot="confirm">Continue</template>
		</small-popup>

		<small-popup id="loginPopupWarning" ref="loginPopupWarning" @popup-confirm="onLeaveGameConfirmedSignIn">
			<template slot="header">{{ loc.feedback_account_deletion_title }}</template>
			<template slot="content">
				<div>{{ loginPopupWarningTxt }}</div>
			</template>
			<template slot="cancel">{{ loc.no }}</template>
			<template slot="confirm">{{ loc.yes }}</template>
		</small-popup>

	<!-- <div id="kotc-play-kotc" class="kotc-play-kotc display-grid">
		<img class="kotc-play-kotc-watermark" src="img/kotc/kotc-crown-indicator.svg" alt="">
		<img class="kotc-play-kotc-arrow" src="img/kotc/kotc-arrow.svg" aria-hidden="true">
	</div> -->
	<!-- #kotc-play-kotc -->
</div> <!-- End of vue instance div -->


<script>
	var vueApp;
	var vueData = {
    ready: false,
    accountSettled: false,
    missingFeatures: [],
	showChangelogHistoryBtn: true,
	itemSearchVal: '',
	changelog: {
		version: '',
		current: [],
		history: [],
		showHistoryBtn: true
	},
	signInAttempts: 0,
	chatInitiatesLogin: false,
	onClickSignIn: false,
	checkProducts: 0,

    firebaseId: null,
    photoUrl: null,
    maskedEmail: null,
    isEmailVerified: false,
    isAnonymous: true,
    showPrivacyOptions: isFromEU,
    isOfAge: false,
    showTargetedAds: false,
    delayTheCracking: false,
    displayAdFunction: Function,
    titleScreenDisplayAd: Function,
    displayAdObject: false,
    hideAds: false,

	feedbackSelected: null,

    isPoki: false,
    isPokiGameLoad: false,
    pokiRewardReady: false,
    isPokiNewRewardTimer: false,
    videoRewardTimers: {
        initial: 300000,
        primary: 420000
    },

    pokiRewNum: 1,


    displayAd: {
        adUnit: {
            home: 'shellshockers_titlescreen',
            nugget: 'shellshockers_chicken_nugget_banner',
            house: 'ShellShockers_LoadingScreen_HouseAds',
			spinner: 'shellshockers_respawn_banner',
			respawn: RESPAWNADUNIT,
			respawnTwo: RESPAWN2ADUNIT,
			respawnThree: RESPAWN3ADUNIT,
			header: 'shellshock-io_728x90_HP',
        },
		header: 0
    },

    cGrespawnBannerTimeout: null,
    cGrespawnBannerErrors: 0,

    classIdx: 0,
    playerName: '',
    eggs: 0,
    kills: 0,
    deaths: 0,
    kdr: 0,
    streak: 0,
	accountCreated: null,
	kdrLifetime: 0,
	statsCurrent: {},
	statsLifetime: {},
	challengesClaimedUnique: 0,
	challengesClaimed : {
		total: 0,
		unique: 0
	},
	eggsSpent: 0,
	eggsSpentMonthly: 0,
	eggsEarnedBalance: 0,
    isUpgraded: false,
    upgradeName: '',
    isSubscriber: false,
	regionList: [], // Populated by Matchmaker API
    currentRegionId: null,
	currentRegionLocKey: '',
    currentGameType: 0,
    volume: 0,
   	getMusicVolume: 0.5,
	selectedWeaponDisabled: false,

    currentLanguageCode: 'en',

	feedbackType: {
		comment: {id: 0, locKey: 'fb_type_commquest'},
		request: {id: 1, locKey: 'fb_type_request'},
		bug: {id: 2, locKey: 'fb_type_bug'},
		purchase: {id: 3, locKey: 'fb_type_purchase'},
		account: {id: 4, locKey: 'fb_type_account'},
		abuse: {id: 5, locKey: 'fb_type_abuse'},
		other: {id: 6, locKey: 'fb_type_other'},
		delete: {id: 7, locKey: 'fb_type_delete'}
	},

	icon: {
		inventory : 'ico-nav-equipment',
		shop: 'ico-nav-shop',
		invite: 'fas fa-user-friends',
		home: 'ico-nav-home',
		user: 'ico-nav-profile',
		settings: 'fas fa-cog',
		fullscreen: 'fas fa-expand-alt',
		egg: 'fas fa-egg',
		dollar: 'fas fa-dollar-sign'
	},

	showScreen: 0,
	previousScreen: 0,
	screens: {
		home: 0,
		equip: 1,
		game: 2,
		profile: 3,
		photoBooth: 4,
	},

	currentEquipMode: null,

	equipMode: {
		inventory: 0,
		gear: 1,
		featured: 2,
		skins: 3,
		shop: 4,
	},

    ui: {
		noob: {
		},
        overlayType: {
            none: 0,
            dark: 1,
            light: 2,
        },
        overlayClass: {
            inGame: 'overlay_game'
        },
        team: {
            blue: 1,
            red: 2
        },
        houseAds: {
            small: null,
            big: null,
			homeScreen: []
        },
        showCornerButtons: true,
		hideUi: false,
		showHomeEquipUi: true,

		events: {
			twitch: false,
		},
		crazyGames: false,

		photoBooth: {
			type: 1,
			vignette: false,
		},

		tutorialPopup: {
			show: false,
			keys: [
				{ locKey: 'keybindings_grenade', cls: 'tutorial-grenade' },
				{ locKey: 'keybindings_melee', cls: 'tutorial-melee' },
				{ locKey: 'keybindings_reload', cls: 'tutorial-reload' },
				{ locKey: 'keybindings_fire', cls: 'tutorial-shoot' },
				{ locKey: 'keybindings_aim', cls: 'tutorial-aim' },
				{ locKey: 'keybindings_jump', cls: 'tutorial-jump' },
				{ locKey: 'keybindings_swapweapon', cls: 'tutorial-swap-weapons' },
				{ locKey: 'tutorial_move_up', cls: 'tutorial-move-up' },
				{ locKey: 'tutorial_move_down', cls: 'tutorial-move-down' },
				{ locKey: 'tutorial_move_left', cls: 'tutorial-move-left' },
				{ locKey: 'tutorial_move_right', cls: 'tutorial-move-right' },
				{ locKey: 'tutorial_q', cls: 'tutorial-q tutorial-special-keys tutorial-key-top text-uppercase text_blue5' },
				{ locKey: 'tutorial_w', cls: 'tutorial-w tutorial-special-keys tutorial-key-top text-uppercase text_blue5' },
				{ locKey: 'tutorial_e', cls: 'tutorial-e tutorial-special-keys tutorial-key-top text-uppercase text_blue5' },
				{ locKey: 'tutorial_r', cls: 'tutorial-r tutorial-special-keys tutorial-key-top text-uppercase text_blue5' },
				{ locKey: 'tutorial_a', cls: 'tutorial-a tutorial-special-keys tutorial-key-bottom text-uppercase text_blue5' },
				{ locKey: 'tutorial_s', cls: 'tutorial-s tutorial-special-keys tutorial-key-bottom text-uppercase text_blue5' },
				{ locKey: 'tutorial_d', cls: 'tutorial-d tutorial-special-keys tutorial-key-bottom text-uppercase text_blue5' },
				{ locKey: 'tutorial_f', cls: 'tutorial-f tutorial-special-keys tutorial-key-bottom text-uppercase text_blue5' },
				{ locKey: 'tutorial_spacebar', cls: 'tutorial-spacebar tutorial-special-keys text-uppercase text_blue5'},
				{ locKey: 'tutorial_move_shift', cls: 'tutorial-shift tutorial-special-keys text-uppercase text_blue5' },
			],
			imgKeys: '',
			imgMouse: '',
		},

		lazyImages: {
			homeEgg1: 'img/eggPose05.webp',
			homeEgg2: 'img/eggPose01.webp',
			vipEmblem: 'img/vip-club/vip-club-popup-emblem.webp',
			vipPayment: 'img/store/UI_paymentOptions.webp',
			vipPopupBg: 'img/vip-club/vip-club-popup-background.webp',
			chwPopup: 'img/chicken-nugget/ssAd_chicknWinner800x600-min.webp',
			rickRoll: 'img/rickroll.gif',
			adBlockPopup: 'img/shellshockers-unite-lg.webp',
			vipImportant: 'img/vip-club/very-important-poultry.webp',
			eggPackSm: 'img/egg_pack_small.webp',
			goldenEgg: 'img/svg/ico_goldenEgg.svg',
			eggOrgGiveStuff: 'img/egg-org/eggOrg_timeTravel_splash800x600-min.webp',
		},

		notification: null,
		bonus: {
			showing: false,
			amount: 1000
		},

		mainMenu: [
			{
				locKey: 'account_title_home',
				icon: 'ico-nav-home',
				screen: 0,
				mode: [],
				hideOn: [2],
			},
			{
				locKey: 'account_title_profile',
				icon: 'ico-nav-profile',
				screen: 3,
				mode: [],
				hideOn: [],
			},
			{
				locKey: 'p_pause_equipment',
				icon: 'ico-nav-equipment',
				screen: 1,
				mode: [0],
				hideOn: [],
			},
			{
				locKey: 'eq_shop',
				icon: 'ico-nav-shop',
				screen: 1,
				mode: [3, 4, 2],
				hideOn: [],
			},
			// {
			// 	locKey: 'screen_photo_booth_menu',
			// 	icon: 'ico-nav-shop',
			// 	screen: 4,
			// 	mode: [],
			// 	hideOn: [],
			// },
		],
		profile: {
			statTab: 0,
			statTabClicked: false
		},
		playerListOverflow: false,
		typeSelectors: [
			{
				img: ItemIcons.Primary,
				type: ItemType.Primary
			},
			{
				img: ItemIcons.Secondary,
				type: ItemType.Secondary
			},
			{
				img: ItemIcons.Stamp,
				type: ItemType.Stamp
			},
			{
				img: ItemIcons.Hat,
				type: ItemType.Hat
			},
			{
				img: ItemIcons.Grenade,
				type: ItemType.Grenade
			},
			{
				img: ItemIcons.Melee,
				type: ItemType.Melee
			}
		],

		socialMedia: {
			footer: [
				{name: 'Facebook', reward: 'Facebook', url: 'https://www.facebook.com/bluewizarddigital', imgPath: 'footer-social-media-bubble-facebook.webp', icon: 'fa-facebook', id: 1227, owned: false},
				{name: 'Twitter', reward: 'Twitter', url: 'https://twitter.com/bluewizardgames', imgPath: 'footer-social-media-bubble-twitter.webp', icon: 'fa-twitter', id: 1234, owned: false},
				{name: 'Instagram', reward: 'Instagram', url: 'https://www.instagram.com/bluewizardgames/', imgPath: 'footer-social-media-bubble-instagram.webp', icon: 'fa-instagram', id: 1219, owned: false},
				{name: 'TikTok', reward: 'tiktok', url: 'https://www.tiktok.com/@bluewizarddigital', imgPath: 'footer-social-media-bubble-tiktok.webp', icon: 'fa-tiktok', id: 1208, owned: false},
				{name: 'Discord', reward: 'discord', url: 'https://discord.gg/bluewizard', imgPath: 'footer-social-media-bubble-discord.webp', icon: 'fa-discord', id: 1200, owned: false},
				{name: 'Steam', reward: 'Steam', url: 'https://store.steampowered.com/publisher/bluewizard', imgPath: 'footer-social-media-bubble-steam.webp', icon: 'fa-steam-symbol', id: 1223, owned: false},
				{name: 'Twitch', reward: 'Twitch', url: 'https://www.twitch.tv/bluewizarddigital', imgPath: 'footer-social-media-bubble-twitch.webp', icon: 'fa-twitch', id: 1268, owned: false},
				{name: 'newYolker', reward: '', url: 'https://bluewizard.com/subscribe-to-the-new-yolker', imgPath: '', icon: 'fa-envelope-open-text', id: null, owned: null},
			],
			selected: ''
		},
		isEvent: {
			active: false,
			houseAdImg: '',
			homeBtnImg: '',
			popupImg: '',
			popupBtnLoc: '',

		},
		premiumFeaturedTag: '',
		game : {
			stats: {
				loading: false
			},
			spectate: false,
			spectatingPlayerName: null
		}
    },

	twitchLinked: 0,
	twitchName: '',
    languages: [
            { name: 'English', code: 'en' },
            { name: 'French', code: 'fr' },
            { name: 'German', code: 'de' },
            { name: 'Russian', code: 'ru' },
            { name: 'Spanish', code: 'es' },
            { name: 'Portuguese', code: 'pt' },
            { name: 'Korean', code: 'ko' },
            { name: 'Chinese', code: 'zh' },
            { name: 'Dutch', code: 'nl' }
        ],

	locLanguage: {},
    playTypes: {
        joinPublic: 0,
        createPrivate: 1,
        joinPrivate: 2
    },

    gameTypes: [
		{ locKey: 'gametype_ffa', value: 0, order: 2 },
        { locKey: 'gametype_teams', value: 1, order: 1 },
        { locKey: 'gametype_ctf', value: 2, order: 0 },
        { locKey: 'gametype_king', value: 3, order: 3 },
    ],
    // This makes me mad, but until Vue is put in the clojure with GameType,
    // where it should have been to begin with, HERE IT IS >:(
	gameTypeKeys: [
        'FFA',
        'Teams',
        'Spatula',
        'King'
    ],

	reportReasons: [
		{ locKey: 'report_reason_cheating', value: 1 },
		{ locKey: 'report_reason_harassment', value: 2 },
		{ locKey: 'report_reason_offensive', value: 4 },
		{ locKey: 'report_reason_other', value: 8 }
	],

	banDurations: [
		{ label: '5 Minutes', value: 0 },
		{ label: '15 Minutes', value: 1 },
		{ label: '1 hour', value: 2 }
	],

    twitchStreams: [],
    youtubeStreams: [],
    newsfeedItems: [],
	maps: [],
    settingsUi: {
		settings: [],
        adjusters: {
            misc: [
                { id: 'volume', locKey: 'p_settings_mastervol', min: 0, max: 1, step: 0.01, value: 1, multiplier: 100 }
            ],
            mouse: [
                { id: 'mouseSpeed', locKey: 'p_settings_mousespeed', min: 1, max: 100, step: 1, value: 30 }
            ],
            gamepad: [
                { id: 'sensitivity', locKey: 'p_settings_sensitivity', min: 1, max: 100, step: 1, value: 30 },
                { id: 'deadzone', locKey: 'p_settings_deadzone', min: 0, max: 1, step: 0.01, value: 0.3, precision: 2 }
            ],
            // music: [
            //     { id: 'musicVolume', locKey: 'p_settings_music_volume', min: 0, max: 1, step: 0.01, value: 0.5,  multiplier: 100 }
            // ],
        },
        togglers: {
            misc: [
                { id: 'holdToAim', locKey: 'p_settings_holdtoaim', value: true },
                { id: 'enableChat', locKey: 'p_settings_enablechat', value: true },
                { id: 'safeNames', locKey: 'p_settings_safenames', value: false },
                { id: 'autoDetail', locKey: 'p_settings_autodetail', value: true },
                { id: 'shadowsEnabled', locKey: 'p_settings_shadows', value: true },
                { id: 'highRes', locKey: 'p_settings_highres', value: false },
                // { id: 'musicStatus', locKey: 'p_settings_music', value: true }
            ],
			misc2: [
                { id: 'hideBadge', locKey: 'p_settings_badge_hide', value: false },
                { id: 'closeWindowAlert', locKey: 'p_settings_close_alert', value: false },
				{ id: 'shakeEnabled', locKey: 'p_settings_shake', value: true },
				{ id: 'centerDot', locKey: 'p_settings_center_dot', value: true },
				{ id: 'hitMarkers', locKey: 'p_settings_hit_markers', value: true },
			],
            mouse: [
                { id: 'mouseInvert', locKey: 'p_settings_invertmouse', value: false },
				{ id: 'fastPollMouse', locKey: 'p_settings_fastpollmouse', value: false },
            ],
            gamepad: [
                { id: 'controllerInvert', locKey: 'p_settings_invertcontroller', value: false },
            ]
        },
        controls: {
            keyboard: {
                // The ids map to the field names in settings.controls[category]
                game: [
                    { id: 'up', side: 'left', locKey: 'keybindings_forward', value: 'W' },
                    { id: 'down', side: 'left', locKey: 'keybindings_backward', value: 'S' },
                    { id: 'left', side: 'left', locKey: 'keybindings_left', value: 'A' },
                    { id: 'right', side: 'left', locKey: 'keybindings_right', value: 'D' },
                    { id: 'jump', side: 'left', locKey: 'keybindings_jump', value: 'SPACE' },
					{ id: 'melee', side: 'left', locKey: 'keybindings_melee', value: 'F' },
					{ id: 'inspect', side: 'left', locKey: 'keybindings_inspect', value: 'G' },
					{ id: 'despawn', side: 'left', locKey: 'keybindings_despawn', value: 'P' },
                    { id: 'fire', side: 'right', locKey: 'keybindings_fire', value: 'MOUSE 0' },
                    { id: 'scope', side: 'right', locKey: 'keybindings_aim', value: 'SHIFT' },
                    { id: 'reload', side: 'right', locKey: 'keybindings_reload', value: 'R' },
                    { id: 'swap_weapon', side: 'right', locKey: 'keybindings_swapweapon', value: 'E' },
                    { id: 'grenade', side: 'right', locKey: 'keybindings_grenade', value: 'Q' },
                ],
                spectate: [
					{ id: 'ascend', locKey: 'keybindings_spectate_ascend', value: 'SPACE' },
					{ id: 'descend', locKey: 'keybindings_spectate_descend', value: 'SHIFT' },
					{ id: 'toggle_freecam', locKey: 'keybindings_spectate_freecam', value: 'V' },
                    { id: 'slow', locKey: 'keybindings_spectate_slow', value: 'MOUSE 0'},
                ]
            },
            gamepad: {
                // The ids map to the field names in settings.gamepad[category]
                game: [
                    { id: 'jump', locKey: 'keybindings_jump', value: '0' },
                    { id: 'fire', locKey: 'keybindings_fire', value: '1' },
                    { id: 'scope', locKey: 'keybindings_aim', value: '2' },
                    { id: 'reload', locKey: 'keybindings_reload', value: '3' },
                    { id: 'swap_weapon', locKey: 'keybindings_swapweapon', value: '4' },
                    { id: 'grenade', locKey: 'keybindings_grenade', value: '5' },
					{ id: 'melee', locKey: 'keybindings_melee', value: '6' },
					{ id: 'inspect', locKey: 'keybindings_inspect', value: '7' }
                ],
                spectate: [
                    { id: 'ascend', locKey: 'keybindings_spectate_ascend', value: '1' },
                    { id: 'descend', locKey: 'keybindings_spectate_descend', value: '2' }
                ]
            }
        }
    },

    songChanged: false,

    music: {
        isMusic: false,
        musicJson: 'data/sponsors.json',
        musicSrc: '',
        theAudio: '',
        playing: false,
        sponsors: {},
        sponsor: '',
        currIndex: 0,
        currentTime: 0,
        duration: 0,
        timer: null,
        progress: 0,
        volume: 10,
        hideClass: 'music-widget--fade-out',
        serverTracks: {
            id: '',
            title: '',
            artist: '',
            album: '',
            albumArt: '',
            url: '',
            trackUrltest: 'https://shellshock.io',
            sponsor: '',
            sponsorUrl: '',
        }
    },

    home: {        
        joinPrivateGamePopup: {
            code: '',
            showInvalidCodeMsg: false,
            validate: function () {
                if (this.code.length == 0) {
                    console.log('failed validation');
                    this.showInvalidCodeMsg =true;
                    BAWK.play('ui_reset');
                    return false;
                }
                console.log('passed validation');
                return true;
            },
            reset: function () {
                this.code = '';
                this.showInvalidCodeMsg = false;
            }
        },
		gaugeData: {
			default: {
				min: 164,
				max: 196,
				default: 180,
			},
			min: 185,
			max: 195,
			loadvalue: 190,
			setValue: 180,
			active: false,
		},
    },

	hvsm: {
		hero: {
			name: 'Heroes',
			items: [],
			img: 'img/gauge-bar/shell_E&E_good_popup.webp',
		},
		monster: {
			name: 'Monsters',
			items: [],
			img: 'img/gauge-bar/shell_E&E_evil_popup.webp',
		},
	},

    equip: {
        get showingItems () {
            return this._showingItems;
        },
        set showingItems (items) {
            this._showingItems = items;
			for (let i = 0; i < this.lazyRenderTimeouts.length; ++i) {
				clearTimeout(this.lazyRenderTimeouts[i]);
			}
        },
        lazyRenderTimeouts: [],
        equippedPrimary: null,
        equippedSecondary: null,
        equippedHat: null,
        equippedStamp: null,
        equippedGrenade: null,
        posingHat: null,
        posingStamp: null,
        posingWeapon: null,
        posingGrenade: null,
        posingMelee: null,
        posingStampPositionX: 0,
        posingStampPositionY: 0,
        showingWeaponType: ItemType.Primary,
        selectedItemType: ItemType.Primary,
		itemSearchTerm:  '',
		itemSearchNone: false,
		itemSearchVal: '',
        selectedItem: null,
        _showingItems: [],
        buyingItem: null,
        colorIdx: 0,
        extraColorsLocked: true,
        categoryLocKey: null,
        showSpecialItems: false,
        specialItemsTag: null,
		showUnVaultedItems: [],
		bundlePopupItems: [],
		chwRewardBuyItem: false,
		displayAdHeaderRefresh: true,
		bundle: {
			owned: false,
			items: [],
		},

        redeemCodePopup: {
            code: '',
            showInvalidCodeMsg: false,
            validate: function () {
                if (this.code.length == 0) {
                    console.log('failed validation');
                    this.showInvalidCodeMsg = true;
                    BAWK.play('ui_reset');
                    return false;
                }
                console.log('passed validation');
                return true;
            },
            reset: function () {
                this.code = '';
                this.showInvalidCodeMsg = false;
            }
        },

        physicalUnlockPopup: {
            item: null
        }
    },

    game: {
		on: false,
		isPaused: true,
        shareLinkPopup: {
            url: ''
        },
        gameType: 0,
        team: 1,
        respawnTime: 0,
        tipIdx: 0,
        isGameOwner: false,
		openPopupId: '',
        pauseScreen: {
            id: 'pausePopup',
            adContainerId: 'pauseAdPlacement',
            classChanged: false,
            wasGameInventoryOpen: false,
			mainContainer: '',
			canvas: '',
			showMenu: true,
        },
		disableRespawn: false,
		mapName: '',
		serverName: '',
		killDeathMsg: {
			showing: false,
			msgs: [],
			msg: '',
			style: '',
			timer: null,
		},
		challengeMsg: {
			showing: false,
			msgs: [],
			icon: '',
			title: '',
			timer: null,
		},
		ctsMsg: {
			showing: false,
			teams: ['', 'blue', 'red'],
			team: 0,
			msg: '',
			timer: null,
		},
		streakMsg: {
			showing: false,
			msg: '',
			count: 0,
			timer: null,
		},
		bestStreak: {
			count: 0,
			timer: null,
		},
		ingameNotification: {
			item: {type: 0, msg: '', streak : 0, style: ''},
			showing: false,
			timer: null,
			multiTimer: null,
		},
		inGameNotification: {
			type: 0,
			timer: null,
		},
		shellStreakTimers: [
			{
				msg: 'ks_double_eggs',
				msgId: 'double-eggs',
			},
			{
				msg: 'ks_miniegg',
				msgId: 'shrink',
			},
			{
				msg: 'ks_dmg',
				msgId: 'egg-breaker',
			},
			{
				msg: 'ks_restock',
				msgId: 'restock',
			}
		]
    },

    isEvent: false,
    doubleEggWeekendSoon: false,
    doubleEggWeekend: false,
    announcementMessage: null,

    playerActionsPopup: {
        playerId: 0,
        uniqueId: 0,
        isGameOwner: false,
        playerName: '',
        muted: false,
        muteFunc: null,
        bootFunc: null,
		reportFunc: null,
        social: false,
        vipMember: false
    },

	banPlayerPopup: {
		reason: ''
	},

	reportPlayerPopup: {
		checked: [false, false, false, false]
	},

    giveStuffPopup: {
        titleLoc: '',
        eggs: 0,
        items: [],
        type: ''
    },

    openUrlPopup: {
        url: '',
        titleLocKey: '',
        contentLocKey: '',
        confirmLocKey: 'ok',
        cancelLocKey: 'no_thanks'
    },

	bannedPopup: {
		expire: ''
	},

    genericMessagePopup: {
        titleLocKey: 'keybindings_right',
        contentLocKey: 'p_popup_chicken_nuggetbutton',
        confirmLocKey: 'ok'
    },

    unsupportedPlatformPopup: {
        titleLocKey: 'unsupported_platform',
        contentLocKey: ''
    },

    windowDimensions: {
        width: 0,
        height: 0,
    },

	bannerAds: {
        bannerElId: '',
    },

    googleAnalytics: {
        isUser: null,
        cat: {
            purchases: 'Purchases',
            purchaseComplete: 'Purchase Complete',
            itemShop: 'Item Shop',
            inventory: 'Inventory',
            playerStats: 'player stats',
            play: 'play game',
            redeem: 'Redeem'
        },
        action : {
            eggShackClick: 'Egg Shack Click',
            eggShackProductClick: 'Egg Shack Product Click',
            purchaseComplete: 'Purchase Complete',
            goldenChickenProductClick: 'Golden Chicken Product Click',
            goldenChickenNuggetClick: 'Golden Chicken Nugget Click',
            shopClick: 'Shop Opened ',
            shopItemClick: 'Shop Item Selected',
            shopItemPopupClick: 'Shop Item Popup Click',
            shopItemPopupBuy: 'Item purchased',
            shopItemNeedMoreEggsPopup: 'Need More Eggs Popup',
            inventorySelected: 'Inventory Item ',
            eggCount: 'Egg Count',
            inventoryTabClick: 'Inventory Opened',
            playGameClick: 'Play Game Click',
            redeemed: 'Redeemed',
            redeemClick: 'Redeem open',
            languageSwitch: 'Language setting change',
            langBeforeUpdate: 'Language before auto detect',
            privateGame: 'Private Game',
            shareGamePopup: 'Share game Popup',
            shareGameCopy: 'Shared game code',
            createGame: 'Created game',
            joinGame: 'Joined game',
            playerLimit: 'Player limit',
            timesPlayed: 'Times played',
            anonymousPopupOpenAuto: 'Anon warning auto opened',
            anonymousPopupOpen: 'Anon warning opened',
            anonymousPopupSignupClick: 'Anon warning Sign in clicked',
            anonymousPopupAgreeClick: 'Anon warning Understood clicked',
            denyAnonUserPopup: 'Deny anon user popup',
            denyAnonUserPopupSignin: 'sign in click',
            faqPopupClick: 'FAQ popup open',
            switchTeams: 'Switched Teams',
            error: 'error',
            signIn: 'Sign in'
        },
        label : {
            signInClick: 'sign in click',
            understood: 'Understood click',
            getMoreEggs: 'Get More Eggs Click',
            waitForGameReadyTimeout: 'waitForGameReady timeout',
            signInAuthFailed: 'authorization failed',
            signInTiming: 'Sign in delay',
            signInCompleted: 'Completed',
            signInOut: 'Signed out',
            signInFailed: '',
            homeToGameLoading: 'Home to game loading',
            loading: 'Loading'
        }
    },

    urlParams: null,
    urlParamSet: null,
    adTagUrl: 'https://pubads.g.doubleclick.net/gampad/ads?iu=/21743024831/ShellShock_Video&description_url=__page-url__&env=vp&impl=s&correlator=&tfcd=0&npa=0&gdfp_req=1&output=vast&sz=640x480&unviewed_position_start=1',

    eggStoreItems: [],
    subStoreItems: [],
    premiumShopItems: [],

    eggStoreReferral:  '',
    eggStoreHasSale:  false,
    eggStorePopupSku:  'egg_pack_small',

    showNugget:  true,
    // isMiniGameComplete:  false,
	miniEggGameAmount:  0,
    showGoldenChicken:  false,
    nugStart:  null,
    nugCounter:  null,
    isBuyNugget:  false,
    adBlockerCountDown:  10,
    controllerType:  'generic',
    controllerId:  '',
    controllerButtonIcons: {
        xbox: [
            'A',
            'B',
            'X',
            'Y',
            'LB',
            'RB',
            'LT',
            'RT',
            'Select',
            'Start',
            '<img class="ss_buttonbind_icon" src="img/controller/button_stickleft.svg">',
            '<img class="ss_buttonbind_icon" src="img/controller/button_stickright.svg">',
            '<img class="ss_buttonbind_icon" src="img/controller/button_dpadup.svg">',
            '<img class="ss_buttonbind_icon" src="img/controller/button_dpaddown.svg">',
            '<img class="ss_buttonbind_icon" src="img/controller/button_dpadleft.svg">',
            '<img class="ss_buttonbind_icon" src="img/controller/button_dpadright.svg">'
        ],
        ps: [
            '<img class="ss_buttonbind_icon" src="img/controller/button_cross.svg">',
            '<img class="ss_buttonbind_icon" src="img/controller/button_circle.svg">',
            '<img class="ss_buttonbind_icon" src="img/controller/button_square.svg">',
            '<img class="ss_buttonbind_icon" src="img/controller/button_triangle.svg">',
            'LB',
            'RB',
            'LT',
            'RT',
            'Select',
            'Start',
            '<img class="ss_buttonbind_icon" src="img/controller/button_stickleft.svg">',
            '<img class="ss_buttonbind_icon" src="img/controller/button_stickright.svg">',
            '<img class="ss_buttonbind_icon" src="img/controller/button_dpadup.svg">',
            '<img class="ss_buttonbind_icon" src="img/controller/button_dpaddown.svg">',
            '<img class="ss_buttonbind_icon" src="img/controller/button_dpadleft.svg">',
            '<img class="ss_buttonbind_icon" src="img/controller/button_dpadright.svg">'
        ],
        switchpro: [
            'B',
            'A',
            'Y',
            'X',
            'LB',
            'RB',
            'LT',
            'RT',
            '-',
            '+',
            '<img class="ss_buttonbind_icon" src="img/controller/button_stickleft.svg">',
            '<img class="ss_buttonbind_icon" src="img/controller/button_stickright.svg">',
            '<img class="ss_buttonbind_icon" src="img/controller/button_dpadup.svg">',
            '<img class="ss_buttonbind_icon" src="img/controller/button_dpaddown.svg">',
            '<img class="ss_buttonbind_icon" src="img/controller/button_dpadleft.svg">',
            '<img class="ss_buttonbind_icon" src="img/controller/button_dpadright.svg">'
        ],
        generic: [
            '0',
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
            '10',
            '11',
            '12',
            '13',
            '14',
            '15'
        ]
    },
    pwaDeferEvent: '',
    blackFridayBanner: false,
	isSale: false,
   	smallHouseAd: {},
    bannerHouseAd: false,
    showAdBlockerVideoAd: false,
    hasMobileReward: false,

    killName: null,
    killedName: null,
    killedByMessage: null,
    killedMessage: null,

	chw: {
		reward: {
			eggs: null,
			itemIds: [],
			ownedItems: null,
		},
		winnerCounter: 0,
		resets: 0,
		winnerDailyLimitReached: false,
		isError: false,
		miniGameComplete: true,
		hasPlayClicked: false,
		onClick: false,
		activeTimer: 6000,
		homeTimer: null,
		homeEl: null,
		signInClicked: false,
		adBlockDetect: false,
		nuggetReset: 0,

		hours: 0,
		minutes: 0,
		seconds: 0,
		progress: 0,
		limitReached: false,
		ready: false,

		imgs: {
			// loot: 'img/chicken-nugget/chickLoop_sleep.svg',
			// speak: 'img/chicken-nugget/chickLoop_speak.svg',
			// limit: 'img/chicken-nugget/chickLoop_daily_limit.svg',
			// sleep: 'img/chicken-nugget/chickLoop_sleep.svg',
			// idle: 'img/chicken-nugget/chickLoop_idle.svg',

			idle: 'img/chicken-nugget/alt/cyborg/chickLoop_idle.svg',
			speak: 'img/chicken-nugget/alt/cyborg/chickLoop_speak.svg',
			limit: 'img/chicken-nugget/alt/cyborg/chickLoop_sleep.svg',
			sleep: 'img/chicken-nugget/alt/cyborg/chickLoop_sleep.svg',
			loot: 'img/chicken-nugget/alt/cyborg/chickLoop_sleep.svg',
		}
	},

	isChicknWinnerError: false,
	chwMiniGameComplete: true,
	hasChwPlayClicked: false,
	chwActiveTimer: 6000,
	chwHomeTimer: null,
	chwHomeEl: null,
	chwSignInClicked: false,

	chwRewardIds: [],

	contentCreator: false,
	eggOrg: false,
	playClicked: false,

	dev: {
		store: {
			sku: null,
			sub: false,
		}
	},

	player: {
		challenges: [],
		challengeDailyData: 0,
		challengeTimer: {
			played: 0,
			alive: 0,
		}
	},

	gameOptionsPopup: {
		resetClicked: false,
		usingDefaults: true,
		changesMade: false,
		options: {},
        togglers: [
			{ id: 'locked', name: 'Locked', locKey: 'game_locked', value: 0 },
			{ id: 'noTeamChange', name: 'Disable Manual Team Change', locKey: 'game_options_manual', value: 0 },
			{ id: 'noTeamShuffle', name: 'Disable Automatic Team Change', locKey: 'game_options_auto', value: 0 }
		],
		adjusters: [
			{ id: 'gravity', locKey: 'game_options_gravity', min: 0.25, max: 1, step: 0.25, value: 1, precision: 2 },
			{ id: 'damage', locKey: 'game_options_damage', min: 0, max: 2, step: 0.25, value: 1, precision: 2 },
			{ id: 'healthRegen', locKey: 'game_options_healthRegen', min: 0, max: 4, step: 0.25, value: 1, precision: 2 }
		]
	},
	
	abTestInventory: {
		closed: false,
		started: false,
		enabled: false,
		reward: {
			item: null,
			eggs: 0,
		},
		clickables: [
			{id: 'shop-menu-item', locKey: 'ab_test_shop', scroll: false, setting: false},
			{id: 'equip-tab-skins', locKey: 'ab_test_skins', scroll: false, setting: false},
			{id: 'type-selector-grenade', locKey: 'ab_test_grenades', scroll: false, setting: false},
			{id: 'item-tag-wero', locKey: 'ab_test_wero', scroll: true, setting: false},
			{id: 'btn_buy_item', locKey: 'ab_test_buy', scroll: false, setting: false},
			{id: '', locKey: '', scroll: false, setting: false},
			{id: 'screens-menu-btn-return', locKey: 'ab_test_back_to_game', scroll: false, setting: 'grenade'},
		],
		currentIdx: 0,
	},
}	// var vueData = new VueData();
</script>

<!-- Shared tags must come before the screen tags -->
<script id="display-ad-template" type="text/x-template">
    <div>
        <div v-show="isAdShowing" :id="id" class="display-ad-container" :class="theClass"></div>
        <house-ad :data="houseAdData" :isshowing="isAdShowing && houseAdData && adBlocker"></house-ad>
    </div>
</script>

<script>
	
// Register popup components globally
Vue.component('display-ad', createDisplayAdComponent('#display-ad-template'));

function createDisplayAdComponent(templateId) {
	return { 
		template: templateId,
        props: ['id', 'adUnit', 'isHidden', 'poki', 'adSize', 'override', 'houseAd', 'ignoreSize', 'noRefresh', 'checkProducts', 'width', 'height'],
		data: function () {
			return {
                isAdShowing: false,
				refreshAllowed: true,
                hideAds: false,
                theAd: '',
                houseAdData: '',
                adBlocker: false,
				finishedSetup: false
				// timerPeriod: 30000,
				// timerId: null,
				// observer: null,
				// isAdVisible: false,

			}
		},
        mounted() {
            this.$nextTick(() => {
                this.getTheAd();
            });
            // this.override = this.override || false;
        },
		methods: {
            getTheAd() {
				if (extern.adsLoaded) {
					return;
				}
                this.theAd = document.getElementById(this.adUnit);

				if (this.finishedSetup) {
					console.log('display ad stop trying to append');
					return;
				}

                const wrap = document.getElementById(this.id);
                wrap.appendChild(this.theAd);

                if (this.houseAd && !crazyGamesActive && !pokiActive) {
                    googletag.cmd.push(function() { googletag.display('ShellShockers_LoadingScreen_HouseAds') });
                }


				this.finishedSetup = true;
				// this.setUpObserver();
            },

			setUpObserver() {
				this.observer = new IntersectionObserver(this.onElObserved, { root: null, threshold: 0.1});
				this.observer.observe(this.theAd);
			},

			onElObserved(ad) {
				this.isAdVisible = Math.floor(ad[0].intersectionRatio * 100) > 10 ? true : false;
			},

			setVisible(visible) {

				if (!visible) {
					this.isAdShowing = false;
				}

				// don't trigger ads if not paused or vip
				if ((visible && !extern.gamePaused && extern.inGame) || extern.productBlockAds) {
					return;
				}

                this.isAdShowing = visible;

				// if (!this.isAdShowing) {
                //    if (!crazyGamesActive) window.removeEventListener('resize', this.hideAdBasedOnscreenSize);
				// } else {
                //     this.triggerAd();
				// 	if (!crazyGamesActive) {
				// 		setTimeout(() => this.hideAdBasedOnscreenSize(), 500);
				// 		window.addEventListener('resize', this.hideAdBasedOnscreenSize);
				// 	}
                // }

				if (this.isAdShowing) {
					this.triggerAd();
				}

            },
			show() {
                if (extern.productBlockAds) return;
                console.log(`display ad container ${this.id} showing`);
                this.setVisible(true);
            },
			hide() {
				console.log(`display ad container ${this.id} hiding`);
                this.setVisible(false);
            },
            crazyGamesAd(id) {
				crazySdk.requestBanner({
                    id: id,
					width: this.width,
					height: this.height,
				});

            },
            triggerAd() {
                this.adBlocker = extern.adBlocker;

                if (this.adBlocker) {
                    this.adblockerSetup();
                    return;
                }

                if (!crazyGamesActive && !testCrazy) {

                    if (this.houseAd) {
                        gtagInHouseLoadingBanner();
                        return;
                    }

					if (this.noRefresh) {
						return;
					}
					
					if (hasValue(this.timerId)) {
						clearTimeout(this.timerId);
						this.timerId = null;
					}

					// Ensure aiptag has a value before setting subid and pushing a command
					if (typeof aiptag === 'undefined' || aiptag === null) {
						return;	
					}

					aiptag.subid = AIPSUBID;

					aiptag.cmd.display.push(() => {
						aipDisplayTag.display(this.adUnit);
						console.log('display ad requested', this.adUnit);
						// this.refreshAllowed = false;
						// this.timerId = window.setTimeout(() => this.refreshAllow(), this.timerPeriod);
					});

                }
            },
			destroyAd() {
				// this.setVisible(false);
				this.setVisible(false);
				if (extern.productBlockAds) {
					return;
				} else {
					if (!crazyGamesActive) {
						console.log('display ad destroy', this.adUnit);
						aiptag.cmd.display.push(() => {
							aipDisplayTag.destroySlot(this.adUnit);
						});
					}
				}
			},
            toggleAd(val) {
				console.log('display ad toggle visibility', this.adUnit, val);
                if (extern.productBlockAds) {
                    this.isAdShowing = false;
                } else {
					this.$nextTick(() => {
						this.isAdShowing = val;
						// if (this.refreshAllowed && val) {
						// 	console.log('display ad toggle triggers refresh', this.adUnit);
						// 	this.triggerAd();
						// }
					});
				}

            },
            adblockerSetup() {
				if (pokiActive) return;

                switch(this.id) {
                    case 'div-gpt-ad-shellshockers-loading-houseads-wrap':
                    case 'shellshockers_respawn_banner_ad':
					case 'shellshockers_respawn_banner-new_ad':
                        this.houseAdData = extern.getHouseAd('bigBanner');
                        break;
                    case 'shellshockers_respawn_banner_2_ad':
                    case 'shellshockers_titlescreen_wrap':
                        this.houseAdData = extern.getHouseAd('small');
                    break;
                    default:
                        console.log('House ads say, huh?');
                }

            },
            hideAdBasedOnscreenSize() {
                let adWidth = this.$el.offsetWidth;
                let intViewportWidth = window.innerWidth;

                if (vueApp.displayAdObject && vueApp.displayAdObject > 1 ) {
                    if (vueApp.displayAdObject < 970) {
                        return;
                    }

                    if (vueApp.displayAdObject > intViewportWidth ) {
                        this.hide();
                    }
                } else {
                    if (adWidth < 970) {
                        return;
                    }

                    if (adWidth > intViewportWidth ) {
                        this.hide();
                    }
                }
            },
            adVisibility() {
                if (this.ignoreSize) return;
                googletag.pubads().addEventListener('slotVisibilityChanged', e => {
                        if (e.inViewPercentage < 51) {
                            this.hide();
                        } else {
                            this.show();
                        }
                    }
                );
            },
			refreshAllow() {
				this.refreshAllowed = true;
				if (this.isAdShowing && this.isAdVisible) {
					console.log('display ad auto refresh', this.adUnit);
					this.triggerAd();
				} else {
					console.log('display ad auto refresh cancelled', this.adUnit);
				}
			}
        },

        computed: {
            theClass() {
                return this.adUnit.toLowerCase().replace(/_/g, "-");
            }
        },
        
        watch: {
            isHidden(value) {
                if (!value) {
                    this.hide();
                }
            },
			checkProducts(val) {
				if (val && extern.productBlockAds) {
					this.hide();
				}
			},
			// isAdVisible(val) {
			// 	console.log('display ad visible', this.adUnit, val);
			// 	if (val && this.isAdShowing && this.refreshAllowed) {
			// 		this.triggerAd();
			// 	}
			// }
        }
	}
}
</script>
<script id="events-template" type="text/x-template">
    <div v-if="showEvent" id="event-notifications">
        <div class="double-eggs f_row align-items-center">
            <img :src="doubleEggEventUrl" />

        </div>
    </div>
</script>
<script>
    const comp_events = {
        template: '#events-template',
        props: ['show', 'currentScreen', 'screens'],
        mounted() {
            this.day = this.now.getUTCDay();
			this.hours = this.now.getUTCHours();
        },
        data() {
            return {
                now: new Date(),
				day: 0,
				hours: 0,
				doubleEggSoonImgSrc: 'img/events/2XEggWeekend_cominSoon.webp',
				doubleEggLiveImgSrc: 'img/events/2XEggWeekend_onNow.webp',
            };
        },
        methods: {
            isEventDate(days) {
                return days.includes(this.day);
            },
        },
		computed: {
			doubleEggWeekendSoon() {
				return this.isEventDate([4]) || this.isEventDate([5]) && this.hours < 20;
			},
			doubleEggWeekend() {
				return this.day >= 5 && this.hours >= 20 || this.isEventDate([6,0]);
			},
			doubleEggEventUrl() {
				if (this.doubleEggWeekendSoon && !this.doubleEggWeekend) {
					return this.doubleEggSoonImgSrc;
				} else if (!this.doubleEggWeekendSoon && this.doubleEggWeekend) {
					return this.doubleEggLiveImgSrc;
				}
			},
			showEvent() {
				return (this.doubleEggWeekendSoon || this.doubleEggWeekend) && this.currentScreen == this.screens.game;
			},
		}
    };
</script><script>
var comp_light_overlay = {
	template: `<transition name="fade">
	<div id="lightOverlay" v-show="show" :class="overlayClass" class="overlay overlay_light"></div>
</transition>`,
	data: function () {
		return {
			show: false,
			overlayClass: '',
		};
	},
};
</script><script>
const comp_dark_overlay = {
  template: `
    <transition name="fade">
      <div v-show="show" :class="overlayClass" :style="overlayStyle"></div>
    </transition>`,
  data() {
    return {
      show: false,
      overlayClass: ''
    };
  },
  computed: {
    overlayStyle() {
      return {
        zIndex: 6, // No need to use quotes for camelCased properties
        backgroundImage: 'none',
        backgroundColor: 'var(--ss-darkoverlay)',
        width: '100%',
        height: '100%',
        position: 'absolute',
        opacity: 1,
        top: 0, // Numerical values don't require quotes
        left: 0
      };
    }
  }
};
</script><script id="spinner-overlay-template" type="text/x-template">
	<transition name="fadeout">
		<div v-show="isShowing" class="load_screen align-items-center">
			<h3 class="load_message">{{ header }}</h3>
			<wobbly-egg></wobbly-egg>
			<p class="load_message">{{ footer }}</p>
			<div v-show="tip && isShowTips" class="spinner-tips display-grid">
				<img v-lazyload :data-src="eggGuyImg" alt="Loading screen egg shouting">
				<p class="load_message tips" v-html="loc[tip]"></p>
			</div>
			<display-ad id="shellshockers_respawn_banner_spinner" ref="loadingScreenDisplayAd" class="pauseFiller" :ignoreSize="false" :adUnit="adUnit" adSize="728x90" width="728" height="90"></display-ad>
		</div>
	</transition>
</script>

<script id="wobble-egg-template" type="text/x-template">
    <div id="wobbly-egg">
        <svg viewBox="0 0 240 240" :class="[loadEggcontainer, {noanimate: noAnimate}]" width="240" height="240" xmlns="http://www.w3.org/2000/svg">
            <defs>
                <radialGradient r="0.5" cy="0.4" cx="0.4" id="load_yolkgradient" spreadMethod="pad">
                    <stop stop-color="#fed" offset="0.3"/>
                    <stop stop-color="#fb0" offset="0.32"/>
                    <stop stop-color="#fa0" offset="1"/>
                </radialGradient>
            
                <filter id="load_eggshadow" :class="{noanimate: noAnimate}" x="-30%" y="-30%" width="160%" height="160%" >
                    <feDropShadow dx="0" dy="8" stdDeviation="8" flood-color="#124" flood-opacity="0.3" />
                </filter>
            </defs>
            <g>
                <path filter="url(#load_eggshadow)" :class="[loadEggwhite, {noanimate: noAnimate}]" stroke="#000" id="svg_eggwhite" d="m190.13055,40.86621c30.25552,23.71378 -12.26575,57.24017 0,81.77167c12.26575,24.5315 4.9063,80.13624 -33.52639,82.58939c-38.43269,2.45315 -55.60474,-26.16693 -94.03742,-17.98977c-38.43269,8.17717 -11.44803,-30.25552 -17.98977,-44.97442c-6.54173,-14.7189 -24.5315,-46.60985 -4.9063,-71.14135c9.8126,-12.26575 22.07835,-14.92333 34.95739,-15.02554c12.87904,-0.10221 19.01191,-15.63883 31.27766,-17.68312c12.26575,-2.04429 21.46506,17.58091 33.83303,11.2436c12.36797,-6.3373 35.26403,-20.64735 50.39179,-8.79045z" stroke-width="0" fill="#fff" />
            </g>
            <g>
                <ellipse :class="[loadEggyolk, {noanimate: noAnimate}]" ry="38" rx="38" id="svg_eggyolk" cy="120" cx="120" stroke-width="0" fill="url(#load_yolkgradient)"/>
            </g>
        </svg>
    </div>
</script>
<script>
    var comp_wobbly_egg = {
        template: '#wobble-egg-template',
        props: ['noAnimate'],
        
        data: function () {
            return {
                loadEggyolk: 'load_eggyolk',
                loadEggwhite: 'load_eggwhite',
                loadEggcontainer: 'load_eggcontainer'
            }
        }
    };
</script>
<script>
var comp_spinner_overlay = {
	template: '#spinner-overlay-template',
	components: {
		'wobbly-egg': comp_wobbly_egg
	},
	props: ['loc', 'adblockerbanner', 'hideAds', 'adUnit', 'accountDate'],
	
	data: function () {
		return {
			isShowing: false,
			header: '',
			footer: '',
			adIsShowing: false,
			isShowTips: false,
			tipKey: null,
			tips: [],
			tip: '',
			eggGuyImg: 'img/shellShockers_loadingTipEgg.webp',
			goodBrowser: true,
			browserTipShown: false,
		}
	},

	mounted() {
		this.isNotChrome().then(result => {
			if (result) {
				this.goodBrowser = false;
			}
		});
	},

	methods: {
		show: function (headerLocKey, footerLocKey, showTips) {
			this.header = this.loc[headerLocKey];
			this.footer = this.loc[footerLocKey];
			this.isShowing = true;
			this.isShowTips = showTips;
		},

		showSpinnerLoadProgress: function (percent) {
			var msg = this.loc['ui_game_loading'];
			this.header = this.loc['building_map'];
			this.footer = '{0}... {1}%'.format(msg, percent);
			this.isShowTips = true;
			this.isShowing = true;
		},

		hide: function () {
			this.isShowing = false;
			this.isShowTips = this.isShowing;
			this.$emit('close-display-ad');
		},

		hideDisplayAd() {
			this.adIsShowing = false;
			console.log('do it');
		},
		showDisplayAd() {
			this.adIsShowing = true;
		},
		toggleDisplayAd() {
			return this.adIsShowing = this.adIsShowing ? false : true;
		},
		getTipKey() {
			if (!this.accountDate) {
				this.tipKey = 'tipNew_';
			} else {
				if (!this.accountDays) {
					this.accountDays = Math.ceil((new Date().getTime() - new Date(this.accountDate).getTime()) / (1000 * 3600 * 24));
				}
				if (this.accountDays <= 14) {
					this.tipKey = 'tipNew_';
				} else {
					this.tipKey = 'tip_';
				}
			}
		},
		randomTip() {
			if (!this.goodBrowser && !this.browserTipShown) {
				this.tip = 'tip_ofthe_day_107';
				this.browserTipShown = true;
				return;
			}

			if (this.tipKey === null) {
				this.getTipKey();
			}

			if (this.tips.length === 0) {
				Object.keys(this.loc).forEach(key => {
					if (key.startsWith(this.tipKey)) {
						this.tips.push(key);
					}
				});
			}
			this.tip = this.tips[Math.floor(Math.random() * this.tips.length)];
		},

		async isNotChrome() {
			if (navigator.userAgentData) {
				const brands = navigator.userAgentData.brands || [];
				const isChrome = brands.some(brand => brand.brand === 'Google Chrome');
				return !isChrome;
			} else {
				// Fallback to userAgent for older browsers
				return this.isNotChromeFallback();
			}
		},
		isNotChromeFallback() {
			const ua = navigator.userAgent;
			return !(ua.includes('Chrome') && !ua.includes('Edg') && !ua.includes('OPR'));
		}
	},
	watch: {
		isShowing(val, old) {
			if (val && !old) {
				this.randomTip();
			}
		}
	}
};
</script><script id="small-popup-template" type="text/x-template">
	<transition name="fade">
		<div v-show="isShowing" class="popup_window popup_sm roundme_md centered">
			<div>
				<button v-show="!hideClose" @click="onXClick" class="roundme_sm popup_close clickme"><i class="fas fa-times text_white fa-2x"></i></button>
				<h3 id="popup_title" v-show="!hideHeader" class="roundme_sm shadow_blue4 nospace text_white">
					<slot name="header"></slot>
				</h3>
			</div>
			<div v-show="!hideContent" class="popup_sm_content"><slot name="content"></slot></div>
			<div id="btn_horizontal" class="f_center">
				<button class="ss_button btn_red bevel_red width_sm" v-show="!hideCancel" @click="cancelClick"><slot name="cancel"></slot></button>
				<button class="ss_button btn_green bevel_green width_sm" v-show="!hideConfirm" @click="confirmClick"><slot name="confirm"></slot></button>
			</div>
			<slot name="footer"></slot>
		</div>
	</transition>
</script>

<script id="large-popup-template" type="text/x-template">
	<transition name="fade">
		<div id="popupPause" v-show="isShowing" class="popup_window popup_lg centered roundme_md" :class="setOverlayCls">
			<button @click="onXClick" v-show="!hideClose" class="popup_close clickme roundme_sm"><i class="fas fa-times text_white fa-2x"></i></button>
			<slot name="content"></slot>
		</div>
	</transition>
</script>

<script>
// Register popup components globally
Vue.component('small-popup', createPopupComponent('#small-popup-template'));
Vue.component('large-popup', createPopupComponent('#large-popup-template'));

function createPopupComponent(templateId) {
	return { 
		template: templateId,
		props: ['hideHeader', 'hideContent', 'hideClose', 'hideCancel', 'hideConfirm', 'overlayType', 'overlayClass', 'popupModel', 'uiModel', 'stopKeyCapture', 'overlayClose'],
		data: function () {
			return {
				isShowing: false,
				overlays: vueData.ui.overlayType,
				popupId: '',
				removeOverlayClick: ''
			}
		},

		created() {
			this.popupId = this.$attrs && this.$attrs.id;
		},

		destroyed: function() {
			document.removeEventListener('keyup', this.escapeKeyClose);
		},

		methods: {
			setVisible: function (visible) {

				this.isShowing = visible;

				if (extern.inGame) {
					if (this.isShowing) {
						extern.releaseKeys();	
					} else {
						extern.captureKeys();
					 }
				}

				if (this.isShowing && this.popupModel && this.popupModel.reset) {
					this.popupModel.reset();
				}

				if (!this.isShowing || this.overlayType === this.overlays.none || this.popupId === 'pausePopup') {
					vueApp.setDarkOverlay(false);
					vueApp.setLightOverlay(false);
				} else {
					vueApp.setDarkOverlay(true);
				}

				if (!this.isShowing) {
					console.log('Closed: ' + this.popupId);
					this.$emit('popup-closed', this.popupId);
					vueApp.$refs.equipScreen.onPopupClosed();
					vueApp.gameUiRemoveClassForNoScroll();
					this.cancelEventOverLayClickEscapeClose();
				} else {
					console.log('Opened: ' + this.popupId);
					this.$emit('popup-opened', this.popupId);
					vueApp.$refs.equipScreen.onPopupOpened();
					vueApp.scrollToTop();
					vueApp.gameUiAddClassForNoScroll();
					this.addEventListeners();
				}
				if (vueApp.showScreen !== vueApp.screens.game) {
					vueApp.toggleTitleScreenAd(this.isShowing ? false : true);
				} else {
					vueApp.toggleRespawnDisplayAd(this.isShowing ? false : true);
				}

			},

			toggle: function () {
				this.isShowing = !this.isShowing;

				this.setVisible(this.isShowing);
			},
			
			show: function () {
				this.setVisible(true);
			},

			hide: function () {
				this.setVisible(false);
			},

			close: function () {
				this.setVisible(false);
				console.log('Closing');
			},

			onCloseClick: function () {
				this.close();
				BAWK.play('ui_popupclose');
			},

			onXClick: function () {
				this.$emit('popup-x');
				this.close();
				BAWK.play('ui_popupclose');
			},

			cancelClick: function () {
				this.close();
				this.$emit('popup-cancel');
				BAWK.play('ui_popupclose');
			},

			confirmClick: function () {
				if (this.popupModel && this.popupModel.validate && !this.popupModel.validate()) {
					return;
				}
				this.close();
				this.$emit('popup-confirm');
				BAWK.play('ui_playconfirm');
			},

			addEventListeners: function() {
				document.addEventListener('click', this.handleOutsideClick);
				document.addEventListener('keyup', this.escapeKeyClose);
			},

			escapeKeyClose: function(e) {
				if (hasValue(this.overlayClose)) {
					return;
				}
				if ((this.overlayClose === undefined || hasValue(this.overlayClose)) && e.keyCode === 27) {
					e.stopPropagation();
					this.onCloseClick();

				}
			},

			handleOutsideClick: function(e) {
				if (this.overlayClose === undefined || this.overlayClose !== false) {
					const clickedElement = e.target;

					// Introduce a small delay (e.g., 10ms) to ensure styles are correctly read... VUE
					setTimeout(() => {

						// Desired styles for comparison
						const desiredStyles = {
							zIndex: '6',
							backgroundImage: 'none',
							backgroundColor: 'var(--ss-darkoverlay)',
							width: '100%',
							height: '100%',
							position: 'absolute',
							opacity: '1',
							top: '0px',
							left: '0px'
						};

						// Function to check if styles match
						const stylesMatch = Object.entries(desiredStyles).every(([key, value]) => {
							const actualValue = clickedElement.style[key];
							const matches = actualValue === value;
							return matches;
						});

						// Proceed only if styles match
						if (stylesMatch) {
							e.stopPropagation();
							this.$emit('popup-x');
							this.onCloseClick();
						}
					}, 10);
				}
			},

			cancelEventOverLayClickEscapeClose: function() {
				document.removeEventListener('click', this.handleOutsideClick);
				document.removeEventListener('keyup', this.escapeKeyClose);
			}
		},
		computed: {
			setOverlayCls() {
				if (extern.inGame) {
					return 'overlay_game';
				}
			}
		}
	}
}
</script>
<script>
    const SvgIcon = {
		template:
			`<svg :class="cls">
				<use :xlink:href="svgName"></use>
			</svg>`,
		props: ['name', 'cls'],
		// data() {
		// 	return {
		// 	};
		// },
		// methods: {
		// },
		computed: {
			svgName() {
				return `#${this.name}`;
			}
		},
	};
    // Register component globally
    Vue.component('icon', SvgIcon);
</script><template id="comp-ss-button" type="text/x-template">
	<button :id="btnId" :class="cls" class="ss_button"><i v-if="iconLeft" class="iconLeft"></i> {{ locTxt }} <i v-if="iconRight" class="iconRight"></i></button>
</template>

<template id="comp-ss-button-dropdown-template" type="text/x-template">
	<button ref="ssDropDown" :id="btnId" @click="onDropdownClick" class="is-for-play ss_button btn_dropdown btn_big common-box-shadow btn_game_mode bg_blue6 text-left box_relative ss-dropdown-select" :class="clsBtn">
		<h3 class="ss-dropdown-select text_blue3" :class="btnId">{{ locTxt.title }}</h3>
		<p class="game-mode-type ss-dropdown-select text_blue5" :class="btnId">{{ locTxt.subTitle }}</p>
		<span class="open-close centered_y ss-dropdown-select" :class="btnId">
			<i class="fas ss-dropdown-select" :class="[caretDirection, btnId, cartOnOpen]"></i>
		</span>
		<div :class="menuPosClass" class="option-box box_absolute roundme_sm common-box-shadow bg_blue6" v-show="isPromptOpen">
			<ul ref="optionBoxList" class="list-no-style nospace ss-dropdown-select f_col">
				<li v-if="listItems" ref="items" v-for="(g, idx) in dropdownList" :class="{ 'selected' : selectedItem === g.value || selectedItem === idx || selectedItem === g.id }" class="display-grid gap-sm align-items-center text_blue5 font-nunito" @click="onListItemClick(g, idx)"><div class="f_row align-items-center"><icon v-show="selectedItem === g.value" class="option-box-checkmark" name="ico-checkmark"></icon></div> {{ listItemTxt(g) }}</li>
				<slot name="dropdown"></slot>
			</ul>
		</div>
	</button>
</template>

<script>
	const createSsBtn = (tempId) => {
		return {
			template: tempId,
			props: ['loc', 'cls', 'locTxt', 'iconRight', 'iconLeft', 'listItems', 'selectedItem', 'menuDown', 'menuPos', 'sort', 'locList'],
			data: function() {
				return {
					isPromptOpen: false,
					btnId: 'btn-' + (Math.random() + 1).toString(36).substring(7),
					onClickVal: null,
					caret: {
						up: 'fa-caret-up',
						down: 'fa-caret-down',
						right: 'fa-caret-right',
						rotate: 'fa-rotate-180'
					}
				}
			},		
			methods: {
				onListItemClick(val, idx) {
					if (val.value !== undefined) {
						this.onClickVal = val.value;
					} else if (val.subdom !== undefined) { 
						this.onClickVal = val.id;
					} else {
						this.onClickVal = idx;
					}
					this.$emit('onListItemClick', this.onClickVal);
				},
				onDropdownClick(e) {
					if (!this.isPromptOpen) {
						this.isPromptOpen = true;
						this.$emit('dropdownOpen');
						document.addEventListener('click', this.onOutsideClick);
					} else {
						this.isPromptOpen = false;
						this.$emit('dropdownClosed');
						document.removeEventListener('click', this.onOutsideClick);
					}
				},
				onOutsideClick(e) {
					if (this.isPromptOpen) {			
						if (e.target.classList.contains(this.btnId) === false) {
							this.isPromptOpen = false;
							this.$emit('dropdownClosed');
							document.removeEventListener('click', this.onOutsideClick);
						}
					}
				},
				listItemTxt(val) {
					if (val.name !== undefined) {
						if (this.locList !== undefined) {
							return this.loc[val.name];
						}
						return val.name;
					} else {
						return this.loc[val.locKey];
					}
				}
			},
			computed: {
				menuPosClass() {
					if (this.menuPos === 'bottom') {
						return 'pos-bottom';
					} else if (this.menuPos === 'right') {
						return 'pos-right';
					}
				},
				caretDirection() {
					if (this.menuPos === 'bottom') {
						return this.caret.down;
					} else if (this.menuPos === 'right') {
						return this.caret.right;
					} else {
						return this.caret.up;
					}
				},
				cartOnOpen() {
					if (this.isPromptOpen) {
						return this.caret.rotate;
					} 
				},
				clsBtn() {
					return `${this.cls} ${this.btnId}`;
				},
				dropdownList() {
					if (this.sort) {
						return this.listItems.sort((a, b) => {
							return a.order - b.order;
						});
					} else {
						return this.listItems;
					}
				}
			},
			watch: {
				isPromptOpen(val) {
					BAWK.play('ui_toggletab');

				}
			}
		};
	}
	Vue.component('ss-button', createSsBtn('#comp-ss-button'));
	Vue.component('ss-button-dropdown', createSsBtn('#comp-ss-button-dropdown-template'));
</script><template id="house-display-ad">
    <transition name="fade">
        <figure v-if="isshowing && data" class="house-wrap">
            <img :src="src" :alt="title" @click="adClicked" />
        </figure>
    </transition>
</template>

<script>
    function createHouseAd() {
        return {
            template: '#house-display-ad',
            props: ['isshowing', 'data'],
            data() {
                return {
                    count: 0
                }
            },
            methods: {
                adClicked() {
                    if ('link' in this.data) {
                        this.data.link = this.data.link + '/?utm_source=shell_shockers&utm_medium=referral&utm_campaign=house-ads';
                    }
                    extern.clickedHouseLink(this.data);
                }
            },
            computed: {
                src() {
                    return dynamicContentPrefix + `data/img/art/${this.data.id}${this.data.imageExt}`;
                },
                alt() {
                    return `${this.data.label} banner image!`;
                },
                link() {
                    return `${this.data.link}/?utm_source=shell_shockers&utm_medium=referral&utm_campaign=house-ads`;
                },
                title() {
                    return `Play ${this.data.label} now!`;
                }

            }
        }
    }

    Vue.component('house-ad', createHouseAd());

</script><script id="language-selector-template" type="text/x-template">
    <select id="pickLanguage" v-model="languageCode" @change="onChangeLanguage" class="ss_select ss_marginright_sm">
        <option v-for="(language, code) in langOptions" v-bind:value="code">
            {{ language }}
        </option>
    </select>

</script>

<script>
var comp_language_selector = {
    template: '#language-selector-template',
    props: ['languages', 'selectedLanguageCode', 'loc', 'langOptions'],

    data: function () {
        return {
            languageCode: this.selectedLanguageCode,
        }
    },

    methods: {
        playSound (sound) {
			BAWK.play(sound);
        },

		onChangeLanguage: function () {
            vueApp.changeLanguage(this.languageCode);
            // Update localStore for selected language.
            localStore.setItem('languageSelected', this.languageCode);
            BAWK.play('ui_onchange');
            ga('send', 'event', {
                eventCategory: vueData.googleAnalytics.cat.playerStats,
                eventAction: vueApp.googleAnalytics.action.languageSwitch,
                eventLabel: this.languageCode,
            });
		}
    },

    watch: {
        selectedLanguageCode: function (code) {
            this.languageCode = code;
        }
    }
};
</script><script id="gdpr-template" type="text/x-template">
    <transition name="fade">
    <div v-show="isShowing">
        <div id="consent" v-show="showingNotification" class="gdpr_banner f_row">
            <div>{{ loc.gdpr_notification }} <a href="http://www.bluewizard.com/privacypolicy" target="_window">{{ loc.gdpr_link }}</a>
            </div>
            <div class="f_row">
                <button @click="onDisagreeClicked()" class="ss_button btn_red bevel_red ss_marginright ss_marginleft">{{ loc.gdpr_disagree }}</button>
                <button @click="onAgreeClicked()" class="ss_button btn_green bevel_green">{{ loc.gdpr_agree }}</button>
            </div>
        </div>

        <div id="doConsent" v-show="showingConsent" class="gdpr_banner f_row">
            <div>{{ loc.gdpr_consent }}</div>
            <div>
                <button @click="close()" class="ss_button btn_green bevel_green btn_md">{{ loc.ok }}</button>
            </div>
        </div>

        <div id="noConsent"v-show="showingNoConsent" class="gdpr_banner f_row">
            <div>{{ loc.gdpr_noConsent }}</div>
            <div>
                <button @click="close()" class="ss_button btn_green bevel_green btn_md">{{ loc.ok }}</button>
            </div>
        </div>
    </div>
    </transition>
</script>

<script>
var comp_gdpr = {
	template: '#gdpr-template',
	props: ['loc'],

    data: function () {
        return {
            isShowing: false,
            showingNotification: false,
            showingConsent: false,
            showingNoConsent: false
        }
    },

	methods: {
        show: function () {
            this.isShowing = true;
            this.showingNotification = true;
            this.showingConsent = false;
            this.showingNoConsent = false;
        },

        close: function () {
            this.isShowing = false;
            BAWK.play('ui_playconfirm');
        },

        onAgreeClicked: function () {
            this.showingConsent = true;
            this.showingNotification = false;
            extern.doConsent();
            BAWK.play('ui_onchange');
        },

        onDisagreeClicked: function () {
            this.showingNoConsent = true;
            this.showingNotification = false;
            extern.doNotConsent();
            BAWK.play('ui_onchange');
        }
    }
};
</script>
<script id="settings-template" type="text/x-template">
  <div>
  	<h1 class="roundme_sm text-center">{{ loc.p_settings_title }}</h1>

	<div class="display-grid grid-column-3-eq gap-sm">
        <button id="keyboard_button" @click="selectTab" class="ss_bigtab bevel_blue roundme_md font-sigmar f_row align-items-center justify-content-center gap-sm" :class="(showKeyboardTab ? 'selected' : '')"><img v-lazyload :data-src="icons.keyboard" class="lazy-load ss_bigtab_icon" /> <img v-lazyload :data-src="icons.mouse" class="lazy-load ss_bigtab_icon" /></button>
        <button id="controller_button" @click="selectTab" class="ss_bigtab bevel_blue roundme_md font-sigmar f_row align-items-center justify-content-center gap-sm" :class="(showControllerTab ? 'selected' : '')"><img v-lazyload :data-src="icons.gamePad" class="lazy-load ss_bigtab_icon" /></button>
        <button id="misc_button" @click="selectTab" class="ss_bigtab bevel_blue ss_bigtab bevel_blue roundme_md font-sigmar f_row align-items-center justify-content-center gap-sm" :class="(showMiscTab ? 'selected' : '')"><img v-lazyload :data-src="icons.monitor" class="lazy-load ss_bigtab_icon" /> <img v-lazyload :data-src="icons.speaker" class="lazy-load ss_bigtab_icon" /> </button>
    </div>

    <div id="popupInnards" class="roundme_sm fullwidth f_col ss_margintop_sm ss_marginbottom_xl">
		<div id="settings_keyboard" v-show="showKeyboardTab" class="settings-section">
			<h3 class="margin-bottom-none h-short">{{ loc.p_settings_keybindings }}</h3>
			
			<div class="f_row ss_margintop">
				<div class="f_col">
					<div v-for="c in settingsUi.controls.keyboard.game" v-if="c.side == 'left'" v-show="showForCrazyGame(c.locKey)"class="nowrap">
						<settings-control-binder :loc="loc" :control-id="c.id" :control-value="c.value" @control-captured="onGameControlCaptured"></settings-control-binder>
						<div class="label">{{ loc[c.locKey] }}</div>
					</div>

					<div class="ss_margintop_xl">
						<div v-for="c in settingsUi.controls.keyboard.spectate" class="nowrap">
							<settings-control-binder :loc="loc" :control-id="c.id" :control-value="c.value" @control-captured="onSpectateControlCaptured"></settings-control-binder>
							<div class="label">{{ loc[c.locKey] }}</div>
						</div>
					</div>
				</div>

				<div class="f_col ss_marginleft_xl">
					<div v-for="c in settingsUi.controls.keyboard.game" v-if="c.side == 'right'" class="nowrap">
						<settings-control-binder :loc="loc" :control-id="c.id" :control-value="c.value" @control-captured="onGameControlCaptured"></settings-control-binder>
						<div class="label">{{ loc[c.locKey] }}</div>
					</div>

					<div class="ss_margintop">
						<div v-for="t in settingsUi.adjusters.mouse" class="nowrap">
							<settings-adjuster :loc="loc" :loc-key="t.locKey" :control-id="t.id" :control-value="t.value" :min="t.min" :max="t.max" :step="t.step" :multiplier="t.multiplier" @setting-adjusted="onSettingAdjusted"></settings-adjuster>
						</div>

						<div v-for="t in settingsUi.togglers.mouse" class="nowrap">
							<settings-toggler v-if="(t.id === 'shadowsEnabled' || t.id === 'highRes') ? showDetailSettings : true" :loc="loc" :loc-key="t.locKey" :control-id="t.id" :control-value="t.value" @setting-toggled="onSettingToggled"></settings-toggler>
						</div>
					</div>

				</div>
			</div>
		</div>
		
		<div id="settings_controller" v-show="showControllerTab" class="settings-section">
			<h3 class="margin-bottom-none h-short">{{ loc.p_settings_gamepadbindings }}</h3>
			
			<div class="f_row ss_margintop">
				<div class="f_col">
					<div v-for="c in settingsUi.controls.gamepad.game" class="nowrap">
						<settings-gamepad-binder :loc="loc" :control-id="c.id" :control-value="c.value" @control-captured="onGamepadGameControlCaptured" :controller-type="controllerType"></settings-gamepad-binder>
						<div class="label">{{ loc[c.locKey] }}</div>
					</div>
				</div>

				<div class="f_col ss_marginleft_xl">
					<div class="ss_marginbottom_xl">
						<div v-for="c in settingsUi.controls.gamepad.spectate" class="nowrap">
							<settings-gamepad-binder :loc="loc" :control-id="c.id" :control-value="c.value" @control-captured="onGamepadSpectateControlCaptured" :controller-type="controllerType"></settings-gamepad-binder>
							<div class="label">{{ loc[c.locKey] }}</div>
						</div>
					</div>

					<div v-for="t in settingsUi.adjusters.gamepad" class="nowrap">
						<settings-adjuster :loc="loc" :loc-key="t.locKey" :control-id="t.id" :control-value="t.value" :min="t.min" :max="t.max" :step="t.step" :multiplier="t.multiplier" :precision="t.precision" @setting-adjusted="onSettingAdjusted"></settings-adjuster>
					</div>

					<div v-for="t in settingsUi.togglers.gamepad" class="nowrap">
						<settings-toggler v-if="(t.id === 'shadowsEnabled' || t.id === 'highRes') ? showDetailSettings : true" :loc="loc" :loc-key="t.locKey" :control-id="t.id" :control-value="t.value" @setting-toggled="onSettingToggled"></settings-toggler>
					</div>
				</div>
			</div>

			<p class="text_blue5 nospace">{{ getControllerId }}</p>
			<p class="text_blue8 nospace">{{ loc.p_settings_controllerhelp }} <a target="_blank" class="text_blue5" href="https://hardwaretester.com/gamepad">hardwaretester.com</a></p>
		</div>

		<div id="settings_misc" v-show="showMiscTab" class="settings-section">
			<div class="display-grid grid-column-2-eq">
				<div class="f_col">
					<div v-for="t in settingsUi.adjusters.misc" class="nowrap">
						<settings-adjuster :loc="loc" :loc-key="t.locKey" :control-id="t.id" :control-value="t.value" :min="t.min" :max="t.max" :step="t.step" :multiplier="t.multiplier" @setting-adjusted="onSettingAdjusted"></settings-adjuster>
					</div>
					<div v-for="t in settingsUi.adjusters.music" class="nowrap">
						<settings-adjuster :loc="loc" :loc-key="t.locKey" :control-id="t.id" :control-value="t.value" :min="t.min" :max="t.max" :step="t.step" :multiplier="t.multiplier" @setting-adjusted="onSettingAdjusted"></settings-adjuster>
					</div>
				</div>

				<div class="f_col">
					<h3 class="margin-bottom-none h-short">{{loc.p_servers_title}}</h3>
					<select id="regionSelect" v-model="currentRegion" @change="onChangeRegion" class="ss_select ss_marginright_sm ss_select">
						<option v-for="(region, id) in regionList" v-bind:value="region.id">{{ loc[region.locKey] }} {{ region.ping }}ms</option>
					</select>
				</div>

				<div class="f_col">
					<h3 class="margin-bottom-none h-short">{{ loc.p_settings_language }}</h3>
					<language-selector :languages="languages" :loc="loc" :selectedLanguageCode="currentLanguageCode" class="ss_select" :langOptions="langOption"></language-selector>
				</div>
			</div>
			<h3 class="margin-bottom-none h-short">More options</h3>
			<div class="display-grid grid-column-2-eq">
				<div class="f_col">
					<div v-for="t in settingsUi.togglers.misc">
						<settings-toggler v-if="(t.id === 'shadowsEnabled' || t.id === 'highRes') ? showDetailSettings : true" v-show="hideSetting(t.id)" :loc="loc" :loc-key="t.locKey" :control-id="t.id" :control-value="t.value" @setting-toggled="onSettingToggled"></settings-toggler>
					</div>
					<button v-if="showPrivacyOptions" @click="onPrivacyOptionsClicked" class="ss_button btn_blue bevel_blue btn_md ss_margintop_xl">{{ loc.p_settings_privacy }}</button>
				</div>
				<div class="f_col">
					<div v-for="t in settingsUi.togglers.misc2">
						<settings-toggler v-if="hideSetting(t.id)" :loc="loc" :loc-key="t.locKey" :control-id="t.id" :control-value="t.value" @setting-toggled="onSettingToggled"></settings-toggler>
					</div>
				</div>
			</div>
		</div>
	</div>

	<div class="display-grid grid-align-items-center justify-items-strech grid-column-3-eq grid-gap-1 fullwidth gap-sm">
		<button @click="onCloseClick" class="ss_button btn_red bevel_red btn_md no_margin_bottom">{{ loc.cancel }}</button>
		<button @click="onResetClick" class="ss_button btn_yolk bevel_yolk btn_md no_margin_bottom">{{ loc.p_settings_reset }}</button>
		<button @click="onSaveClick" class="ss_button btn_green bevel_green btn_md no_margin_bottom">{{ loc.confirm }}</button>
	</div>

  </div>
</script>

<script id="settings-control-binder-template" type="text/x-template">
	<input ref="controlInput" @change="BAWK.play('ui_onchange')" type="text" v-model="currentValue" :placeholder="loc.press_key" class="ss_keybind clickme text_blue8" :class="(currentValue === 'undefined' ? 'ss_keybind_undefined' : '')"
		v-on:mousedown="onMouseDown($event)"
		v-on:keydown="onKeyDown($event)" 
		v-on:keyup="onKeyUp($event)" 
		v-on:wheel="onWheel($event)"
		v-on:focusout="onFocusOut($event)">
</script>

<script>
var comp_settings_control_binder = {
	template: '#settings-control-binder-template',
	props: ['loc', 'controlId', 'controlValue'],
	
	data: function () {
		return {
			currentValue: this.controlValue,
			isCapturing: false
		}
	},

	methods: {
		playSound (sound) {
			BAWK.play(sound);
		},
		
		reset: function () {
			this.currentValue = (this.controlValue === null) ? 'undefined' : this.controlValue;
			this.isCapturing = false;
			this.$refs.controlInput.blur();
		},

		capture: function (value) {
			this.isCapturing = false;
			this.$refs.controlInput.blur();
			this.$emit('control-captured', this.controlId, value);
		},

		onMouseDown: function (event) {
			if (!this.isCapturing) {
				this.currentValue = '';
				this.isCapturing = true;
			} else {
				BAWK.play('ui_onchange')
				this.capture('MOUSE ' + event.button);
			}
		},

		onKeyDown: function (event) {
			this.currentValue = '';
			event.stopPropagation();
		},

		onKeyUp: function (event) {
			event.stopPropagation();
			var key = event.key;

			if (key == 'Escape' || key == 'Tab' || key == 'Enter') {
				return;
			}

			if (key == ' ') {
				key = 'space';
				event.preventDefault();
			}
			
			this.capture(key);
		},

		onWheel: function (event) {
			if (this.isCapturing) {
				BAWK.play('ui_onchange')
				if (event.deltaY > 0) {
					this.capture('WHEEL DOWN');
				} else if (event.deltaY < 0) {
					this.capture('WHEEL UP');
				}
			}
		},

		onFocusOut: function (event) {
			this.reset();
		}
	},

	watch: {
		// The value prop gets updated by the parent control; watch for changes and update the backing field of the textbox
		controlValue: function (newValue) {
			this.currentValue = (newValue === null) ? 'undefined' : newValue;
		}
	}
};
</script><script id="settings-gamepad-binder-template" type="text/x-template">
	<button ref="gamepadInput" class="ss_keybind clickme" :class="(currentValue === 'undefined' ? 'ss_keybind_undefined' : '')"
		v-on:mousedown="onMouseDown($event)"
		v-on:keydown="onKeyDown($event)" 
		v-on:keyup="onKeyUp($event)" 
		v-on:focusout="onFocusOut($event)"
		:key="controllerType">
		<span v-html="currentValue"></span></button>
</script>

<script>
var comp_settings_gamepad_binder = {
	template: '#settings-gamepad-binder-template',
	props: ['loc', 'controlId', 'controlValue', 'controllerType'],
	
	data: function () {
		return {
			currentValue: (this.controlValue === null) ? 'undefined' : vueData.controllerButtonIcons[this.controllerType][this.controlValue],
			isCapturing: false
		}
	},

	beforeUpdate: function () {
		if (!this.isCapturing) {
			this.setIcon(this.controlValue);
		}
	},

	methods: {
		playSound (sound) {
			BAWK.play(sound);
		},
		
		reset: function () {
			this.setIcon(this.controlValue);
			this.isCapturing = false;

			removeEventListener('gamepadbuttondown', this.onButtonDown);
			removeEventListener('gamepadbuttonup', this.onButtonUp);
		},

		capture: function (value) {
			this.isCapturing = false;
			this.$refs.gamepadInput.blur();
			this.$emit('control-captured', this.controlId, value);
			this.reset();
		},

		onMouseDown: function (event) {
			if (!this.isCapturing) {
				this.currentValue = this.loc.press_button;
				this.isCapturing = true;

				addEventListener('gamepadbuttondown', this.onButtonDown);
				addEventListener('gamepadbuttonup', this.onButtonUp);
			}
		},

		onKeyDown: function (event) {
			event.stopPropagation();
		},

		onKeyUp: function (event) {
			event.stopPropagation();
		},

		onButtonDown: function (event) {
			if (event.detail == 8 || event.detail == 9) return;
			BAWK.play('ui_onchange')
			this.capture(event.detail);
		},

		onFocusOut: function (event) {
			this.reset();
		},

		setIcon: function (value) {
			this.currentValue = (value === null) ? 'undefined' : vueData.controllerButtonIcons[this.controllerType][value];
		}
	},

	watch: {
		// The value prop gets updated by the parent control; watch for changes and update the backing field of the textbox
		controlValue: function (newValue) {
			this.setIcon(newValue);
		}
	}
};
</script><script id="settings-adjuster-template" type="text/x-template">
	<div>
		<h3 v-if="!smallHeader" class="margin-bottom-none h-short" v-html="loc[locKey]"></h3>
		<label v-if="smallHeader" class="label" v-html="loc[locKey]"></label>

		<div class="f_row">
			<input class="ss_slider" :disabled="disabled" type="range" :min="min" :max="max" :step="step" v-model="currentValue" @change="onChange">
			<label class="ss_slider label text_blue4">{{ getCurrentValue() }}{{ labelSuffix }}</label>
		</div>
	</div>
</script>

<script>
var comp_settings_adjuster = {
	template: '#settings-adjuster-template',
	props: ['loc', 'smallHeader', 'locKey',
		'controlId', 'controlValue', 'disabled',
		'min', 'max', 'step', 'multiplier',
		'precision', 'labelSuffix'
	],

	data: function () {
		return {
			currentValue: this.controlValue
		}
	},

	methods: {
		onChange: function (event) {
			this.$emit('setting-adjusted', this.controlId, this.currentValue);
			BAWK.play('ui_onchange');
		},

		getCurrentValue: function () {
			if (this.precision) {
				return Number.parseFloat(this.currentValue).toFixed(this.precision);
			}
			else {
				return Math.floor(this.currentValue * (this.multiplier || 1));
			}
		}
	},

	watch: {
		// controlValue prop could change when player X's out or clicks Cancel
		controlValue: function (newValue) {
			if (this.currentValue !== newValue) {
				this.currentValue = newValue;
			}
		}
	}
};
</script><script id="settings-toggler-template" type="text/x-template">
	<label v-if="!hide" class="ss_checkbox label"> {{ loc[locKey] }}
		<input type="checkbox" v-model="currentValue" @change="onChange($event)">
		<span class="checkmark"></span>
	</label>
</script>

<script>
var comp_settings_toggler = {
	template: '#settings-toggler-template',
	props: ['loc', 'locKey', 'controlId', 'controlValue', 'hide'],

	data: function () {
		return {
			currentValue: this.controlValue
		}
	},

	methods: {
		onChange: function (event) {
			this.$emit('setting-toggled', this.controlId, this.currentValue);
			BAWK.play('ui_onchange');
		}
	},

	watch: {
		// controlValue prop could change when player X's out or clicks Cancel
		controlValue: function (newValue) {
			if (this.currentValue !== newValue) {
				this.currentValue = newValue;
			}
		}
	}
};
</script>
<script>
var comp_settings = {
	template: '#settings-template',
	components: {
		'settings-control-binder': comp_settings_control_binder,
		'settings-gamepad-binder': comp_settings_gamepad_binder,
		'language-selector': comp_language_selector,
		'settings-adjuster': comp_settings_adjuster,
		'settings-toggler': comp_settings_toggler
	},
	props: ['loc', 'settingsUi', 'languages', 'currentLanguageCode', 'showPrivacyOptions', 'controllerId', 'isFromEU', 'controllerType', 'langOption', 'isVip', 'regionList', 'currentRegionId'],

	data: function () {
		return {
			showKeyboardTab: true,
			showControllerTab: false,
			showMiscTab: false,

			originalSettings: {},
			showDetailSettings: false,
			originalLanguage: '',
			originalMusicVolume: '',
			musicStatChg: '',
			currentRegion: '',
			icons: {
				keyboard: 'img/ico_keyboard.svg',
				mouse: 'img/ico_mouse.svg',
				gamePad: 'img/ico_gamepad.svg',
				monitor: 'img/ico_monitor.svg',
				speaker: 'img/ico_speaker.svg'
			}
		}
	},
	
	methods: {
		onChangeRegion() {
			if (vueData.currentRegionId !== this.currentRegion) {
				extern.selectRegion(this.currentRegion);
				BAWK.play('ui_onchange');
			}
		},

		selectTab: function (e) {
			return this.switchTab(e.target.id)
		},
		
		switchTab(tab) {

			this.showKeyboardTab = false;
			this.showControllerTab = false;
			this.showMiscTab = false;

			switch (tab) {
				case 'keyboard_button':
					this.showKeyboardTab = true;
					break;

				case 'controller_button':
					this.showControllerTab = true;
					break;

				case 'misc_button':
					this.showMiscTab = true;
					break;
			}

			BAWK.play('ui_toggletab');
		},

		captureOriginalSettings: function () {
			this.originalSettings = deepClone(vueData.settingsUi);
			this.originalLanguage = this.currentLanguageCode;
			// this.originalMusicVolume = this.originalSettings.adjusters.music[0].value;
		},

		applyOriginalSettings: function () {
			vueData.settingsUi = this.originalSettings;
			this.showDetailSettings = !vueData.settingsUi.togglers.misc.find( a => { return a.id === 'autoDetail'; }).value;

			console.log('applying original settings: ' + JSON.stringify(vueData.settingsUi));
		},

		onGameControlCaptured: function (id, value) {
			this.onControlCaptured(this.settingsUi.controls.keyboard.game, id, value)
		},

		onSpectateControlCaptured: function (id, value) {
			this.onControlCaptured(this.settingsUi.controls.keyboard.spectate, id, value)
		},

		onGamepadGameControlCaptured: function (id, value) {
			this.onControlCaptured(this.settingsUi.controls.gamepad.game, id, value)
		},

		onGamepadSpectateControlCaptured: function (id, value) {
			this.onControlCaptured(this.settingsUi.controls.gamepad.spectate, id, value)
		},

		onControlCaptured: function (controls, id, value) {
			value = value.toLocaleUpperCase();

			controls
				.forEach( (c) => {
					if (c.id === id) {
						c.value = value;
					} else {
						if (c.value === value) {
							c.value = null;
						}
					}
			});
		},

		onSettingToggled: function (id, value) {
			console.log('value: ' + value);

			Object.values(this.settingsUi.togglers).forEach(v => {
				var toggler = v.find(t => { return t.id === id; });
				if (toggler) toggler.value = value;
			})

			if (id === 'autoDetail') {
				this.showDetailSettings = !value;
			}

			if (id === 'safeNames') {
				extern.setSafeNames(value);
			}

			// if (id === 'musicStatus') {
			// 	extern.setMusicStatus(value);
			// 	this.musicStatChg = true;

			// 	if (extern.inGame) {
			// 		vueApp.toggleMusic();
			// 	}
			// }
		},

		onSettingAdjusted: function (id, value) {
			Object.values(this.settingsUi.adjusters).forEach(v => {
				var adjuster = v.find( (a) => { return a.id === id; });
				if (adjuster) adjuster.value = value;
			})

			if (id === 'volume') {
				extern.setVolume(value);
			}

			if (id === 'mouseSpeed') {
				extern.setMouseSpeed(value);
			}

			if (id === 'sensitivity') {
				extern.setControllerSpeed(value);
			}

			if (id === 'deadzone') {
				extern.setDeadzone(value);
			}

			if (id === 'musicVolume') {
				extern.setMusicVolume(value);
			}

		},

		onVolumeChange: function () {
			extern.setVolume(this.settingsUi.volume);
		},

		onPrivacyOptionsClicked: function () {
			this.$emit('privacy-options-opened');
			BAWK.play('ui_popupopen');
		},
		
		onCancelClick: function () {
			this.applyOriginalSettings();
			//extern.setMusicVolume(this.originalMusicVolume);
			this.cancelLanguageSelect();
			if (this.musicStatChg) {
				if (extern.inGame) { 
					vueApp.toggleMusic();
				}
			};
			this.$parent.close();
		},

		onCloseClick: function () {
			this.applyOriginalSettings();
			//extern.setMusicVolume(this.originalMusicVolume);
			this.cancelLanguageSelect();
			if (this.musicStatChg) {
				if (extern.inGame) {
					vueApp.toggleMusic();
				}
			};
			vueApp.sharedIngamePopupClosed();
			this.$parent.toggle();
			BAWK.play('ui_popupclose');
		},

		quickSave() {
			extern.applyUiSettings(this.settingsUi, this.originalSettings);
			this.resetOriginalLanguage();		
		},
		
		onSaveClick: function () {
			// if (vueApp.music.serverTracks.title) {
			// 	this.gaMusicVol();
			// }
			// this.gaMusicVol();

			extern.applyUiSettings(this.settingsUi, this.originalSettings);
			this.resetOriginalLanguage();
			vueApp.sharedIngamePopupClosed();
			this.$parent.toggle();
			BAWK.play('ui_playconfirm');
			this.sendChangesToGa(this.originalSettings, this.settingsUi);
		},

		sendChangesToGa(originalSettings, currentSettings) {
			const changes = [];

			function compareSettingsArray(type, category, originalArray, currentArray) {
				originalArray.forEach((originalItem, index) => {
					const currentItem = currentArray[index];

					// Check if value has changed
					if (originalItem.value !== currentItem.value) {
						changes.push({
							type,
							category,
							id: originalItem.id,
							originalValue: originalItem.value,
							newValue: currentItem.value
						});
					}
				});
			}

			function compareSettings(type, original, current) {
				Object.keys(current).forEach(category => {
					compareSettingsArray(type, category, original[category], current[category]);
				});
			}

			compareSettings('adjusters', originalSettings.adjusters, currentSettings.adjusters);
			compareSettings('togglers', originalSettings.togglers, currentSettings.togglers);
			
			Object.keys(currentSettings.controls).forEach(inputType => {
				compareSettings(`controls_${inputType}`, originalSettings.controls[inputType], currentSettings.controls[inputType]);
			});

			function hasDecimal(value) {
				return typeof value === 'number' && !Number.isInteger(value);
			}

			changes.forEach(el => {
				let val = el.newValue;

				if (el.type === 'adjusters') {
					let toNumber = Number(val);
					val = hasDecimal(toNumber) ? Math.round(toNumber * 100) : toNumber;
				}
				ga('send', 'event', 'game', 'settings', el.id, val);
			});
		},

		gaMusicVol() {
			let newVol = Number(this.settingsUi.adjusters.music[0].value);
			if (newVol === Number(this.originalMusicVolume)) return;
			if ((Math.round(newVol*100)) <= 1) {
				ga('send', 'event', 'music', 'mute', vueApp.music.serverTracks.title);
			}
		},
		onResetClick: function () {
			extern.resetSettings();
			BAWK.play('ui_reset');
		},
		cancelLanguageSelect: function() {
			this.originalLanguage === vueApp.$data.currentLanguageCode ?
				vueApp.changeLanguage(vueApp.$data.currentLanguageCode) : vueApp.changeLanguage(this.originalLanguage);
			// Revert localStore for language
			localStore.setItem('languageSelected', this.originalLanguage);
			this.resetOriginalLanguage();
		},
		resetOriginalLanguage: function() {
			this.originalLanguage = '';
		},
		setSettings: function (settings) {
			var getSettingById = (list, id) => {
				return list.filter( o => {
						return o.id == id;
				})[0];
			};

			// Keyboard

			getSettingById(this.settingsUi.controls.keyboard.game, 'up').value = settings.controls.keyboard.game.up;
			getSettingById(this.settingsUi.controls.keyboard.game, 'down').value = settings.controls.keyboard.game.down;
			getSettingById(this.settingsUi.controls.keyboard.game, 'left').value = settings.controls.keyboard.game.left;
			getSettingById(this.settingsUi.controls.keyboard.game, 'right').value = settings.controls.keyboard.game.right;
			getSettingById(this.settingsUi.controls.keyboard.game, 'jump').value = settings.controls.keyboard.game.jump;
			getSettingById(this.settingsUi.controls.keyboard.game, 'melee').value = settings.controls.keyboard.game.melee;
			getSettingById(this.settingsUi.controls.keyboard.game, 'inspect').value = settings.controls.keyboard.game.inspect;
			getSettingById(this.settingsUi.controls.keyboard.game, 'fire').value = settings.controls.keyboard.game.fire;
			getSettingById(this.settingsUi.controls.keyboard.game, 'scope').value = settings.controls.keyboard.game.scope;
			getSettingById(this.settingsUi.controls.keyboard.game, 'reload').value = settings.controls.keyboard.game.reload;
			getSettingById(this.settingsUi.controls.keyboard.game, 'swap_weapon').value = settings.controls.keyboard.game.swap_weapon;
			getSettingById(this.settingsUi.controls.keyboard.game, 'grenade').value = settings.controls.keyboard.game.grenade;
			getSettingById(this.settingsUi.controls.keyboard.spectate, 'ascend').value = settings.controls.keyboard.spectate.ascend;
			getSettingById(this.settingsUi.controls.keyboard.spectate, 'descend').value = settings.controls.keyboard.spectate.descend;
			getSettingById(this.settingsUi.controls.keyboard.spectate, 'toggle_freecam').value = settings.controls.keyboard.spectate.toggle_freecam;
			getSettingById(this.settingsUi.controls.keyboard.spectate, 'slow').value = settings.controls.keyboard.spectate.slow;

			// Gamepad

			getSettingById(this.settingsUi.controls.gamepad.game, 'jump').value = settings.controls.gamepad.game.jump;
			getSettingById(this.settingsUi.controls.gamepad.game, 'fire').value = settings.controls.gamepad.game.fire;
			getSettingById(this.settingsUi.controls.gamepad.game, 'scope').value = settings.controls.gamepad.game.scope;
			getSettingById(this.settingsUi.controls.gamepad.game, 'reload').value = settings.controls.gamepad.game.reload;
			getSettingById(this.settingsUi.controls.gamepad.game, 'swap_weapon').value = settings.controls.gamepad.game.swap_weapon;
			getSettingById(this.settingsUi.controls.gamepad.game, 'grenade').value = settings.controls.gamepad.game.grenade;
			getSettingById(this.settingsUi.controls.gamepad.game, 'melee').value = settings.controls.gamepad.game.melee;
			getSettingById(this.settingsUi.controls.gamepad.game, 'inspect').value = settings.controls.gamepad.game.inspect;
			getSettingById(this.settingsUi.controls.gamepad.spectate, 'ascend').value = settings.controls.gamepad.spectate.ascend;
			getSettingById(this.settingsUi.controls.gamepad.spectate, 'descend').value = settings.controls.gamepad.spectate.descend;

			// Misc

			getSettingById(this.settingsUi.adjusters.misc, 'volume').value = settings.volume;
			// getSettingById(this.settingsUi.adjusters.music, 'musicVolume').value = settings.musicVolume;
			getSettingById(this.settingsUi.adjusters.mouse, 'mouseSpeed').value = settings.mouseSpeed;
			getSettingById(this.settingsUi.adjusters.gamepad, 'sensitivity').value = settings.controllerSpeed;
			getSettingById(this.settingsUi.adjusters.gamepad, 'deadzone').value = settings.deadzone;

			getSettingById(this.settingsUi.togglers.mouse, 'mouseInvert').value = (settings.mouseInvert !== 1);
			getSettingById(this.settingsUi.togglers.mouse, 'fastPollMouse').value = settings.fastPollMouse;
			getSettingById(this.settingsUi.togglers.gamepad, 'controllerInvert').value = (settings.controllerInvert !== 1);

			getSettingById(this.settingsUi.togglers.misc, 'holdToAim').value = settings.holdToAim;
			getSettingById(this.settingsUi.togglers.misc, 'enableChat').value = settings.enableChat;
			getSettingById(this.settingsUi.togglers.misc, 'safeNames').value = settings.safeNames;
			getSettingById(this.settingsUi.togglers.misc, 'autoDetail').value = settings.autoDetail;
			getSettingById(this.settingsUi.togglers.misc, 'shadowsEnabled').value = settings.shadowsEnabled;
			getSettingById(this.settingsUi.togglers.misc, 'highRes').value = settings.highRes;
			getSettingById(this.settingsUi.togglers.misc2, 'hideBadge').value = settings.hideBadge;
			getSettingById(this.settingsUi.togglers.misc2, 'closeWindowAlert').value = settings.closeWindowAlert;
			getSettingById(this.settingsUi.togglers.misc2, 'shakeEnabled').value = settings.shakeEnabled;
			getSettingById(this.settingsUi.togglers.misc2, 'centerDot').value = settings.centerDot;
			getSettingById(this.settingsUi.togglers.misc2, 'hitMarkers').value = settings.hitMarkers;
			// getSettingById(this.settingsUi.togglers.misc, 'musicStatus').value = settings.musicStatus;

			console.log('auto detail: ' + settings.autoDetail);
			this.showDetailSettings = !settings.autoDetail;
		},

		hideSetting(id) {
			if (id === 'hideBadge') {
				return this.isVip;
			}
			return true;
		},

		onHelpClickDelete() {
			vueApp.hideSettingsPopup();
			vueApp.showHelpPopupFeedbackWithDelete();
			ga('send', 'event', vueApp.googleAnalytics.cat.playerStats, vueApp.googleAnalytics.action.faqPopupClick);
			BAWK.play('ui_popupopen');
		},

		showForCrazyGame(locRef) {
			return locRef !== 'keybindings_despawn' || crazyGamesActive;
		}
	},
	computed: {
		getControllerId() {
			if (this.controllerId == 'No controller detected') {
				return vueApp.loc['p_settings_nocontroller']
			} else {
				return this.controllerId
			}
		}
	},
	watch: {
		currentRegionId(val) {
			if (this.currentRegion !== val) {
				this.currentRegion = val;
			}
		}
	}
};
</script><script id="help-template" type="text/x-template">
    <div>
       <div class="f_row align-items-center  justify-content-center">
            <button id="faq_button" @click="toggleTabs" class="ss_bigtab bevel_blue ss_marginright roundme_md font-sigmar" :class="(showTab1 ? 'selected' : '')">{{ loc.faq }}</button>
            <button id="fb_button" @click="toggleTabs" class="ss_bigtab bevel_blue roundme_md font-sigmar" :class="(!showTab1 ? 'selected' : '')">{{ loc.feedback }}</button>
        </div>
        <div v-show="showTab1">
            
            <div id="feedback_panel">      

                <h1>{{ loc.faq_title }}</h1>

				<help-questions :content="localizeThis"></help-questions>

                <hr>
                <div id="btn_horizontal" class="f_center">
	            	<button @click="onBackClick" class="ss_button btn_md btn_red bevel_red ss_marginright">{{ loc.cancel }}</button>
                </div>
                
            </div>            
        </div>

        <div v-show="!showTab1">
	        
	        <div id="feedback_panel">
	            <h1 :class="{'text-center' : isAccountDeleteReq}">{{ feedbackTitle }}</h1>
	            
	            <p v-if="!isAccountDeleteReq">{{ loc.fb_feedback_intro }}</p>
				<h4 v-if="isNoAccountForDelete" class="text-center">{{loc.feedback_sign_in_msg}}</h4>

				<div id="btn_horizontal" class="f_center">
	                <select v-model="selectedType" class="ss_field ss_marginright" @click="BAWK.play('ui_click')" @change="BAWK.play('ui_onchange')">
	                    <option v-for="type in feedbackType" :value="type.id">{{ loc[type.locKey] }}</option>
	                </select>
	            
	                <input id="feedbackEmail" v-model="email" :placeholder="loc.fb_email_ph" class="ss_field" v-on:keyup="validateEmail">
				</div>
				
				<div>
	                <textarea v-if="!isAccountDeleteReq" id="feedbackText" class="ss_field" v-model="feedback" :placeholder="loc.fb_feedback_ph" v-on:keyup="validateMessage"></textarea>
				</div>
				
				<div class="f_center f_col">
					<span v-show="emailInvalid" class="ss_marginright error_text">{{ loc.fb_bad_email }}</span>
					<span v-show="messageInvalid" class="ss_marginright error_text">{{ loc.fb_no_comment }}</span>
				</div>
				
	            <div id="btn_horizontal" class="f_center">
	            	<button @click="onBackClick" class="ss_button btn_md btn_red bevel_red ss_marginright">{{ loc.cancel }}</button>
	                <button @click="onSendClick" class="ss_button btn_md btn_green bevel_green">{{ sendBtnText }}</button>
	            </div>
            </div>

        </div>
    </div>
</script>

<script id="help-question-template" type="text/x-template">
    <div>
		<div v-for="qa in content">
			<a :name="qa[0]"></a>
			<h3>{{ qa[1] }}</h3>
			<span v-html="qa[2]"></span>
		</div>
    </div>
</script>

<script>
var comp_help_question = {
    template: '#help-question-template',
    props: ['content'],
};
</script>
<script>
var comp_help = {
    template: '#help-template',
	components: {
        'help-questions': comp_help_question,
	},
	props: ['loc', 'accountType', 'feedbackType', 'openWithType'],
	mounted() {
		this.helpLocSetup();
	},
    data: function () {
        return {
            showTab1: true,
            selectedType: 0,
            email: '',
            feedback: '',
            doValidation: false,
            emailInvalid: false,
            messageInvalid: false,
			qaNum: [1,2,3,4,5,6,7,8,9,10,11],
			newLoc: [],
			localizeThis:  [],
			

        }
    },
    feedbackValidateTimeout: 0,
    methods: {
		playSound (sound) {
			BAWK.play(sound);
        },
        
        validateEmail: function () {
            if (!this.doValidation) {
                return;
            }
            // Insane e-mail-validating regex
            var re = /(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])/;
            
            this.emailInvalid = (this.email === '' || !re.test(this.email));
            return !this.emailInvalid;
        },

        validateMessage: function () {
            if (!this.doValidation) {
                return;
            }
            this.messageInvalid = this.feedback === '';
            return !this.messageInvalid;
        },

        toggleTabs: function () {
            this.showTab1 = !this.showTab1;
			this.selectedType = 0;
			this.$emit('resetFeedbackType');
            BAWK.play('ui_toggletab');
			if ( !this.showTab1) {
				ga('send', 'event', 'feedback opened');
			}
        },
        
        onBackClick: function () {
            vueApp.$refs.helpPopup.toggle();
            BAWK.play('ui_popupclose');
        },

		sendFeedbackApi(selected) {
			if (!selected) {
				selected = this.selectedType;
			}

            extern.api_feedback(selected, this.email, this.feedback);

            setTimeout(() => {
                if (this.selectedType !== this.feedbackType.delete.id) {
					this.$parent.toggle();
				}
                this.selectedType = 0;
                this.feedback = null;
                this.email = null;
            }, 900);
		},
		
        onSendClick: function () {
			if (this.isNoAccountForDelete) {
				vueApp.hideHelpPopup();
				vueApp.showFirebaseSignIn();
				return;
			}
            this.doValidation = true;

			if (this.selectedType === this.feedbackType.delete.id) {
				this.comment = null;
				this.$parent.toggle();
				vueApp.showDeleteAccoutApprovalPopup();
				BAWK.play('ui_popupopen');
				return;
			} else {
				if (!this.validateEmail() || !this.validateMessage() ) {
					return;
				}
			}

			BAWK.play('ui_playconfirm');

            // Send that shit out
            this.sendFeedbackApi();
        },

		onAccountDelectionConfirmed() {
			this.sendFeedbackApi(this.feedbackType.delete.id);
		},

		helpLocSetup(locContent) {
			let content = this.loc;
			// if (locContent) {
			// 	content = locContent
			// }
			const locArray = Object.entries(content);
			this.newLoc = locArray.filter( (item, i) => {
				if (item[0].includes('faqItems_q')) {
					return item;
				}
			});

			const tranlateThat = [];

			for (let n = 0; n < this.qaNum.length; n++) {
				tranlateThat.push([]);
				for (let i = 0; i < this.newLoc.length; i++) {
					if (this.newLoc[i][0].includes('faqItems_q' + this.qaNum[n] + '_')) {
						tranlateThat[n].push(this.newLoc[i][1]);
					}
				}
			}
			// Cause once again... vue
			setTimeout(() => {this.localizeThis = tranlateThat}, 500);
		},
		openFeedbackTabWith(type) {
			this.showTab1 = false;
			if (type) {
				this.selectedType = type;
			}
		}
    },
	computed: {
		isAccountDeleteReq() {
			return this.selectedType === this.feedbackType.delete.id;
		},
		isNoAccountForDelete() {
			return this.isAccountDeleteReq && this.accountType == 'no-account';
		},
		sendBtnText() {
			if (this.isNoAccountForDelete) {
				return this.loc.sign_in;
			} else {
				return this.loc.fb_send;
			}
		},
		feedbackTitle() {
			if (!this.isAccountDeleteReq) {
				return this.loc.fb_feedback_title;
			} else {
				return this.loc.fb_delete_account;
			}
		}
	},
	watch: {
		loc(val) {
			this.helpLocSetup(val);
		},
	}
};
</script><script id="vip-help-template" type="text/x-template">
    <div>
        <div id="feedback_panel">      
            <h1>{{ loc.vipHelptitle }}</h1>
            <strong><small class="text_yellow"><i class="fas fa-exclamation-triangle"></i> {{loc.vipHelpDesc2}}</small></strong>
            <p>{{loc.vipHelpDesc}}</p>

			<div>
				<a :name="loc.vipFaqItems_q1_anchor"></a>
				<h3>{{ loc.vipFaqItems_q1_q }}</h3>
				<p>{{ loc.vipFaqItems_q1_a_1 }}</p>
				<ul>
					<li>{{ loc.vipFaqItems_q1_li_1 }}</li>
					<li>{{ loc.vipFaqItems_q1_li_2 }}</li>
					<li>{{ loc.vipFaqItems_q1_li_3 }}</li>
					<li>{{ loc.vipFaqItems_q1_li_4 }}</li>
					<li>{{ loc.vipFaqItems_q1_li_5 }}</li>
					<li>{{ loc.vipFaqItems_q1_li_6 }}</li>
				</ul>
			</div>

			<div>
				<a :name="loc.vipFaqItems_q2_anchor"></a>
				<h3>{{ loc.vipFaqItems_q2_q }}</h3>
				<p>{{ loc.vipFaqItems_q2_a_1 }}</p>
			</div>

			<div>
				<a :name="loc.vipFaqItems_q3_anchor"></a>
				<h3>{{ loc.vipFaqItems_q3_q }}</h3>
				<p>{{ loc.vipFaqItems_q3_a_1 }}</p>
			</div>

			<div>
				<a :name="loc.vipFaqItems_q4_anchor"></a>
				<h3>{{ loc.vipFaqItems_q4_q }}</h3>
				<p>{{ loc.vipFaqItems_q4_a_mobile_3 }}</p>
				<p>{{ loc.vipFaqItems_q4_a_1 }}</p>
				<p>{{ loc.vipFaqItems_q4_a_2 }}</p>
			</div>

			<div>
				<a :name="loc.vipFaqItems_q5_anchor"></a>
				<h3>{{ loc.vipFaqItems_q5_q }}</h3>
				<p>{{ loc.vipFaqItems_q5_a_1 }}</p>
				<p>{{ loc.vipFaqItems_q5_a_2 }}</p>
				<p>{{ loc.vipFaqItems_q5_a_3 }}</p>
			</div>

			<div>
				<a :name="loc.vipFaqItems_q6_anchor"></a>
				<h3>{{ loc.vipFaqItems_q6_q }}</h3>
				<p>{{ loc.vipFaqItems_q6_a_1 }}</p>
				<p>{{ loc.vipFaqItems_q6_a_2 }}</p>
				<p>{{ loc.vipFaqItems_q6_a_3 }}</p>
			</div>

			<div>
				<a :name="loc.vipFaqItems_q7_anchor"></a>
				<h3>{{ loc.vipFaqItems_q7_q }}</h3>
				<p>{{ loc.vipFaqItems_q7_a_1 }}</p>
			</div>

<!-- 
            <div v-for="qa in loc.vipFaqItems">
                <a :name="qa.anchor"></a>
                <h3>{{ qa.q }}</h3>
                <p v-for="p in qa.a">
                   {{p}}
                </p>
                <ul v-if="qa.li">
                    <li v-for="li in qa.li">{{li}}</li>
                </ul>
            </div> -->

            <hr>
            <div id="btn_horizontal" class="f_center">
                <button @click="openVipStore" class="ss_button btn_md btn_green bevel_green ss_marginright">{{ subButtonTxt }}</button>
                <button @click="onBackClick" class="ss_button btn_md btn_red bevel_red ss_marginright">{{ loc.cancel }}</button>
            </div>

        </div>
    </div>
</script>

<script>
var vip_help = {
    template: '#vip-help-template',
    props: ['loc', 'isVip'],
    data: function () {
        return {

        }
    },
    methods: {
        onBackClick() {
            BAWK.play('ui_popupclose');
            this.$parent.hide();
        },
        openVipStore() {
            this.$parent.hide();
            vueApp.showSubStorePopup();
        }
    },
    computed: {
        subButtonTxt() {
            return this.isVip ? this.loc.sManageBtn : this.loc.account_vip;
        }
    }
};
</script><script id="house-ad-big-template" type="text/x-template">
    <div v-show="(useAd !== null)">
        <button @click="onCloseClicked" class="popup_close splash_ad_close ad_close"><i class="fas fa-times text_white fa-2x"></i></button>
        <img :src="adImageUrl" @click="onClicked" class="splash_ad_image centered roundme_md">
    </div>
</script>

<script>
var comp_house_ad_big = {
    template: '#house-ad-big-template',
    data: function() {
        return {
            removeOverlayClick: '',
        }
    },
    
    props: ['useAd'],

    bigAdTimeout: null,

    methods: {
        onCloseClicked: function () {
            console.log('big ad closed');
            this.close();
        },

        onClicked: function () {
            this.close();
            BAWK.play('ui_click');
            extern.clickedHouseAdBig(this.useAd);
        },

        close: function () {
            if (this.useAd === null) {
				return;
			}
            BAWK.play('ui_popupclose');
            this.$emit('big-house-ad-closed');
        },

        outsideClickClose: function() {
            const showingId = document.getElementById('house-ad-big-template', true);
            this.removeOverlayClick = this.handleOutsideClick;
            document.addEventListener('click', this.removeOverlayClick);
        },
        
        handleOutsideClick: function(e) {
            // Stop bubbling
            e.stopPropagation();
            // If the target does NOT include the class splash_ad_image use the onCloseClicked method and remove the eventListener
            if ( ! e.target.id.includes('splash_ad_image') ) {
                this.onCloseClicked();
                document.removeEventListener('click', this.removeOverlayClick);
            }
        },
    },

    computed: {
        adImageUrl: function () {
            if (!hasValue(this.useAd)) {
                return;
            }

            return dynamicContentPrefix + 'data/img/art/{0}{1}'.format(this.useAd.id, this.useAd.imageExt);
        }
    },

    watch: {
        useAd: function (bigAd) {
            if (hasValue(bigAd)) {
				setTimeout(() => {
					vueApp.hideTitleScreenAd();
				}, 100);
                this.$options.bigAdTimeout = setTimeout(function () {
                    vueApp.ui.houseAds.big = null;
                }, 15000);
                // Close with outside click
                this.outsideClickClose();
            } else {
				vueApp.showTitleScreenAd();
			}
        }
    }
};
</script><script id="house-ad-small-template" type="text/x-template">
    <img v-show="(useAd !== null)" :src="adImageUrl" @click="onClicked" class="news_banner roundme_md">
</script>

<script>
var comp_house_ad_small = {
    template: '#house-ad-small-template',
    
    props: ['useAd'],

    methods: {
        onClicked: function () {
            BAWK.play('ui_click');
            extern.clickedHouseAdSmall(this.useAd);
        }
    },

    computed: {
        adImageUrl: function () {
            if (!hasValue(this.useAd)) {
                return;
            }
            ga('send', 'event', {
				eventCategory: 'House banner ad',
				eventAction: 'show',
				eventLabel: this.useAd.label
			});

            return dynamicContentPrefix + 'data/img/art/{0}{1}'.format(this.useAd.id, this.useAd.imageExt);
        }
    }
};
</script>
<script id="item-template" type="text/x-template">
	<div v-if="active" class="box_relative center_h" ref="itemObserver">
		<div :class="tooltip" ref="theTooltip">
			<span v-if="showTooltip" class="paddings_sm display-grid">
				<div>
					<h4 class="nospace text_yolk">{{ itemName }}</h4>
				</div>
				<!-- <p class="nospace text_blue5">{{ tooltipTxt.desc }}</p> -->
			</span>
			<div ref="eggItemInvetory" class="grid-item roundme_lg clickme common-box-shadow box_relative" :class="[itemClass, itemType, itemTagsString]" @click="onClick">
				<div v-show="!renderDone" class="centered"><i class="fas fa-egg fa-spin fa-2x"></i></div>
				<span v-if="isVipItem">
					<icon name="ico-vip" class="equip-vip-icon"></icon>
				</span>
				<div v-if="hasBanner && !notify" class="equip-item-banner shadow">
					<span class="visibility-hidden">{{bannerTxt}}</span>
				</div>
				<div v-if="hasBanner && !notify" class="equip-item-banner">
					{{bannerTxt}}
				</div>
				<div v-if="showPrice && renderDone" class="equip_smallprice display-grid box_absolute grid-column-auto-1 gap-sm">
					<div class="equip_cost box_absolute f_row align-items-center" :class="equipCostTagCls">
						<i v-if="isPremium && !isItemOwned" :class="priceIcon"></i><span v-if="!isPremium && !isItemOwned && !hidePrice" class="egg-price-egg"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" xml:space="preserve"><path class="egg-fill" d="M12 21.6c-4.4 0-8-3.5-8-7.8 0-4 3.4-11.4 8.1-11.4 4.8 0 7.8 7.5 7.8 11.4.1 4.3-3.5 7.8-7.9 7.8z" style="fill-rule:evenodd;clip-rule:evenodd;"/><path class="egg-stroke" d="M12.1 3.9c3.6 0 6.3 6.4 6.3 9.9s-2.9 6.3-6.5 6.3-6.5-2.8-6.5-6.3c.1-3.5 3.2-9.9 6.7-9.9m0-3C6.2.9 2.5 9.4 2.5 13.8c0 5.2 4.3 9.3 9.5 9.3s9.5-4.2 9.5-9.3C21.5 9.4 18.2.9 12.1.9z"/></svg>
</span>{{ itemPrice }}
					</div>
				</div>
				<canvas ref="itemCanvas" class="equip_icon centered" :class="canvasCls" width="250" height="250"></canvas>
				<div v-if="notify && hasBanner" class="notification-banner box_relative">
					<img :src="bannerIconImg" alt="">
				</div>
				<p v-if="showItemOnly" class="item-name text-center">{{ item.name }}</p>
			</div>
			<button class="ss_button btn_green bevel_green btn_sm fullwidth ss_margintop box_absolute" v-show="hasBuyBtn && isSelected" @click="onClickBuy">Get it now!</button>
		</div>
	</div>
</script>

<script>
var comp_item = {
	template: '#item-template',
	props: ['loc', 'item', 'showItemOnly', 'isSelected', 'equippedSlot', 'hasBuyBtn', 'isShop', 'hidePrice', 'showTooltip', 'notify'],

	data: function () {
		return {
			itemOnly: hasValue(this.showItemOnly) ? this.showItemOnly : false,
			active: true,
			itemLimited: false,
			itemUnlock: 'purchase',
			itemTags: [],
			itemTagsString: '',
			renderDone: false,
			observer: null,
			premTxt: {
				title: '',
				desc: ''
			}
		}
	},

	mounted() {
		this.$nextTick(() => {
			this.setupObserver();
		});
		this.prepareItem();
		this.itemHightlightedOrder();
	},

	beforeDestroy() {
		// Disconnect the observer when the component is destroyed
		if (this.observer) {
			this.observer.disconnect();
		}
	},

	methods: {
		setupObserver() {
			// Ensure the itemObserver element exists
			const targetElement = this.$refs.itemObserver;
			if (targetElement && targetElement instanceof HTMLElement) {
				this.observer = new IntersectionObserver(this.onIntersection, {
				root: null, // observe in the viewport
				threshold: 0.1 // trigger when 10% of the item is visible
				});
				this.observer.observe(targetElement);
			} else {
				console.error('itemObserver element not found or not an HTMLElement.');
			}
		},
		onIntersection(entries) {
			const entry = entries[0];
			if (entry.isIntersecting && !this.renderDone) {
				setTimeout(() => {
					this.renderItem();
					this.observer.disconnect(); // Stop observing after rendering
				}, 0);
			}
		},
		prepareItem: function () {
			this.itemUnlock = this.item.unlock;

			if (this.itemUnlock == 'premium' && !this.item.activeProduct && this.isShop) {
				this.active = false;
			}

			// We don't need this mess
			if (this.itemUnlock === 'physical' && this.isShop) {
				this.active = false;
			}
			
			this.setUpTags();
			this.isEquippedSlot();
			// this.tooltipOnMouseOver();
		},
		setUpTags() {
			if (this.item.item_data !== undefined && this.item.item_data.tags !== undefined && this.item.item_data.tags.length) {
				this.item.item_data.tags.forEach(el => this.itemTags.push('item-tag-' + el.toLowerCase().replace(/\s+/g, '-')));
				this.itemTagsString = this.itemTags.toString().replace(/,/g, ' ');
			}
		},

		isEquippedSlot() {
			if (this.equippedSlot) {
				this.active = true;
			}
		},

		tooltipOnMouseOver() {
			const tooltip = this.$refs.theTooltip;
			const itemGrid = document.getElementById('item-smack-down');
			const searchBox = document.getElementById('item-search-wrap');

			tooltip.addEventListener("mouseover", () => {
				// Cache the bounding rectangles
				const tooltipBounds = tooltip.getBoundingClientRect();
				const itemGridBounds = itemGrid.getBoundingClientRect();
				const searchBoxBounds = searchBox.getBoundingClientRect();

				// Use constants to avoid recalculating values
				const tooltipY = Math.floor(tooltipBounds.y);
				const searchBoxY = Math.floor(searchBoxBounds.y);
				const itemGridY = Math.floor(itemGridBounds.y);
				const tooltipLeft = Math.floor(tooltipBounds.left - 10);
				const tooltipRight = Math.floor(tooltipBounds.right + 10);
				const itemGridLeft = Math.floor(itemGridBounds.left);
				const itemGridRight = Math.floor(itemGridBounds.right);

				// Determine conditions
				const elTouchSearch = tooltipY < searchBoxY;
				const topTouch = tooltipY === itemGridY;
				const leftTouch = tooltipLeft < itemGridLeft;
				const rightTouch = tooltipRight > itemGridRight;

				// Add or remove classes based on conditions
				tooltip.classList.toggle('tooltip-bottom', topTouch && !rightTouch && !leftTouch);
				tooltip.classList.toggle('tooltip-left', leftTouch);
				tooltip.classList.toggle('tooltip-right', rightTouch);
			});
		},

		highlightSelected: function () {
			return this.isSelected ? 'highlight' : '';
		},

		itemHightlightedOrder: function() {
			if (this.isPhysicalMerch && vueData.currentEquipMode == vueData.equipMode.shop) return;
			return this.$refs.eggItemInvetory.classList.contains('highlight') ? this.$refs.eggItemInvetory.style.order='-1' : null;
		},

		renderItem() {
			if (this.$refs.itemCanvas === undefined) {
				return;
			}
			extern.renderItemToCanvas(this.item, this.$refs.itemCanvas, () => {
				this.renderDone = true;
			});
		},

		onClick: function () {
			this.$emit('item-selected', this.item);
		},

		onClickBuy() {
			extern.buyProductForMoney(this.item.sku[0]);
		},
		countWords (str) {
			str = str.trim();
			const words = str.match(/\S+/g);

			words.forEach((w, i) => {
				if (w.length > 10) {
					const wLength = Math.floor(w.length / 2);
					const newWord = w.substring(0, wLength) + '-' + w.substring(wLength, w.length);
					words[i] = newWord;
				}
			});
			return words.join(' ');
		},

	},

	computed: {
		dataItem() {
			return this.item.name.toLowerCase().replace(/\s+/g, '-');
		},
		isItemSellable: function () {
			return (!this.itemOnly && vueData.currentEquipMode == vueData.equipMode.shop) || (!this.itemOnly && vueData.currentEquipMode == vueData.equipMode.skins) || (!this.itemOnly && vueData.currentEquipMode == vueData.equipMode.featured);
		},

		showPrice () {
			return  this.isItemSellable && this.item.price > 0;
		},

		isPhysicalMerch () {
			return this.isItemSellable && this.itemUnlock === 'physical';
		},

		isPremium() {
			return this.itemUnlock === 'premium' && !this.itemTags.includes('item-tag-vipitem');
		},

		isVipItem() {
			return this.itemUnlock === 'vip';
		},

		isLimited() {
			return this.itemTags.includes('item-tag-limited');
		},

		isDrop() {
			return this.itemTags.includes('drop');
		},

		isItemOwned() {
			return extern.isItemOwned(this.item);
		},

		hasBanner() {
			return this.isPremium || this.isVipItem || this.isLimited || this.isPremiumEggPurchase;
		},

		isPremiumEggPurchase() {
			return this.itemUnlock === 'purchase' && this.itemTags.includes('item-tag-premium') && this.item.price > 150000;
		},

		itemType() {
			return getKeyByValue(ItemType, this.item.item_type_id).toLowerCase();
		},

		bannerTxt() {
			if (!this.hasBanner) {
				return;
			} else {
				if (this.isPremium || this.isPremiumEggPurchase) {
					return 'PREMIUM';
				}
				if (this.isVipItem) {
					return 'VIP';
				}
				if (this.isLimited) {
					return this.loc.eq_limited;
				}
			}
		},

		canvasCls() {
			if (!this.isItemSellable) {
				return 'full-width-height'
			}
		},

		itemClass() {
			return {
				'is-premium': this.isPremium || this.isPremiumEggPurchase,
				'is-vip': this.isVipItem,
				'highlight': this.isSelected,
			}
		},

		itemPrice() {
			if (this.hidePrice) {
				if (this.isItemOwned ) {
					return this.loc.eq_owned;
				}
			} else {
				return !this.isItemOwned ? this.item.price : this.loc.eq_owned + '!';
			}
		},

		priceIcon() {
			if (this.isPremium) {
				return vueApp.icon.dollar;
			}
		},
		equipCostTagCls() {
			if (this.isPremium && !this.isItemOwned) {
				return 'premium-item-cost';
			} else if (this.isItemOwned) {
				return 'equip-cost-is-owned';
			}
		},
		tooltipTxt() {
			if (this.showTooltip) {
				return this.premTxt;
			}
		},
		tooltip() {
			if (this.showTooltip) {
				return 'tool-tip';
			}
		},
		bannerIconImg() {
			if (this.isPremium) {
				return 'img/store/PremiumTag.webp';
			} else if (this.isVipItem) {
				return 'img/store/VIPTag.webp';
			}
		},
		itemName() {
			return this.countWords(this.item.name);
		}
	},

	watch: {
		item: function (val) {
			this.prepareItem();
		}
	}
};
</script><script id="chickn-winner-template" type="text/x-template">
    <div id="popupInnards" class="box_dark roundme_sm fullwidth f_col">
		<header class="display-grid grid-column-1-eq align-items-center roundme_lg">
			<h1 class="chickn-winner-title nospace text-center">{{ loc.p_chicken_header_txt}}</h1>
		</header>
		<section id="chickn-winner-wrapper" class="egg-chick-wrapper f_row roundme_lg box_relative justify-content-center">
			<div v-show="eggGameReady" class="egg-chick-box box_relative" v-for="egg in eggs" :key="egg.id">
				<div v-if="showAmountRewarded && busted && egg.value > 5" class="text-center chw-reward-amount box_absolute">
					<h2 class="box_relative shadow_grey">{{ showAmountRewarded }} <img class="chw-winner-egg" src="img/ico_goldenEgg.svg" /></h2>
				</div>
				<img class="incentivized-egg-chick box_relative" :class="eggClass(egg.value)" @click="checkIfReady" :src="eggSrc(egg.value)" :id="egg.id">
				<div v-if="rewardHasItem && egg.value > 5" class="centered">
					<item :loc="loc" :item="rewardItem" :has-buy-btn="false" :is-shop="false"></item>
					<h4 class="text_white text-center nospace text-shadow-black-40">{{ rewardItem.name }}</h4>
				</div>
			</div>
			<img v-show="!eggGameReady" class="incentivized-egg-chick centered" :src="chickSrc">
			<button v-show="showAdWatch" class="ss_button btn_large btn_green bevel_green btn_shiny ss_marginbottom_lg" @click="watchVideo">{{ loc.chw_btn_watch_ad }}</button>
			<h2 class="centered nospace fullwidth text-center">{{ txtState.desc }}</h2>
			<div v-show="!chw.ready && !chw.adBlockDetect"class="chw-progress-bar-wrap-popup roundme_sm box_relative bg_blue5 center_h ss_marginbottom_lg ss_button">
				<p class="chw-progress-bar-msg box_absolute centered nospace text-center fullwidth chw-msg chw-p-msg text_white">
					<span v-show="chw.hours" class="chw-pie-num">{{chw.hours}}:</span><span class="chw-pie-num">{{chw.minutes}}:</span><span class="chw-pie-num">{{chw.seconds}}</span>
				</p>
				<div class="chw-progress-bar-inner-popup bg_blue4" :style="{width: chwBarProgress}"></div>
			</div>
		</section>
		<!-- #chickn-winner-wrapper -->
		<footer class="nugget-footer text-center box_relative">
			<div>
			<button v-show="showPopupBtn" id="gotWinnerOk" @click="onGotWinner" class="ss_button btn_medium btn_yolk bevel_yolk btn_shiny">{{ txtState.btn }}</button>
			<button v-show="!firebaseId" @click="signIn" class="ss_button btn_medium btn_green bevel_green btn_shiny">{{ loc.sign_in}}</button>
			</div>
		</footer>
    </div>
	<!-- #popupInnards -->
</script>


<script>
var comp_chickn_winner_popup = {
    template: '#chickn-winner-template',
    props: ['loc', 'firebaseId', 'reward', 'adUnit', 'chw'],
	components: {
		'item': comp_item,
	},

    data: function () {
        return {
			clickedIdx: 0,
			eggs: [{id:'eggOne', value: 0, active: true, hide: 0}, {id:'eggTwo', value: 0, active: true, hide: 0}, {id:'eggThree', value: 0, active: true, hide: 0}],
			isMiniGameComplete: false,
			bustedSrc: `img/incentivized-mini-game/svg/Egg07.svg`,
			busted: false,
			showEggGame: false,
			clickBeforeReady: false,
			watchAdClicked: false,
			show: false
		}
    },

    methods: {
        placeBannerAdTag: function (tagEl) {
            this.$refs.chickenNuggetAdContainer.appendChild(tagEl);
        },
		eggSrc(count) {
			if (count > 6) {
				return `img/incentivized-mini-game/svg/Egg06.svg`;
			}
			return `img/incentivized-mini-game/svg/Egg0${count}.svg`;
		},

		eggSrcBusted() {
			setTimeout(() => {
				return `img/incentivized-mini-game/svg/Egg07.svg`;
			}, 2424);
		},

		eggBg(count) {
			if (count > 5) {
				return 'incentivized-show'
			}
		},
		eggClass(count) {
			let hide;
			if (count > 5 && this.reward.itemIds.length > 0) {
				hide = 'visibility-hidden cyborg-egg';
			}
			if (count > 5) {
				return `chick-alive ${hide} egg-${count} cyborg-egg`;
			}
		},

		checkIfReady(e) {
				this.eggClickCounter(e);
		},

		eggClickCounter(e) {
			if (!this.busted) {
				BAWK.play('mini-egg-game_shellhit');
			} else {
				BAWK.play('mini-egg-game_chick');
			}

			this.clickedIdx = this.eggs.findIndex(i => i.id === e.target.id);

			let elem = document.getElementById(this.eggs[this.clickedIdx].id);

			if (this.eggs[this.clickedIdx].value < 6) {
				elem.classList.add('chickn-winner-clicked');
				setTimeout(() => elem.classList.remove('chickn-winner-clicked'), 650);
			}

				if (this.eggs[this.clickedIdx].value === 5) {

					this.isMiniGameComplete = true;

					ga('send', 'event', 'Chickn Winner', 'Egg Game', `egg-cracked-${this.eggs[this.clickedIdx].id}`);

					setTimeout(() => {
						this.eggs[this.clickedIdx].active = false;
						elem.src = this.bustedSrc;
					}, 1414);

					this.busted = true;

					extern.api_checkBalance();

					this.eggs.forEach(i => {
						if (i.id === e.target.id) return;
						let btn = document.getElementById(i.id);
						if (btn) {
							btn.style.pointerEvents = 'none';
							btn.disabled = true;
						}
					});
				}


			if (this.eggs[this.clickedIdx].value === 100) {
				BAWK.play('mini-egg-game_shial');
			}

			this.eggs[this.clickedIdx].value++;
		},
		resetGame() {
			if (this.firebaseId !== null) {
				extern.checkStartChicknWinner();
			}
			if (extern.inGame) {
				vueApp.disableRespawnButton(false);
				vueApp.showGameMenu();
			}
			setTimeout(() => {
				this.$emit('chw-mini-game-complete', true);
				this.isMiniGameComplete = false;
				this.busted = false;
				this.reward.eggs = null;
				this.reward.itemIds.length = 0;
				this.reward.ownedItem = null;
				this.reward.ownedItems = null;
				this.clickBeforeReady = false;
				this.watchAdClicked = false;

				this.eggs.forEach(i => {
					const Btn = document.getElementById(i.id);
					if (Btn) {
						Btn.style.pointerEvents = 'all';
						Btn.disabled = false;
					}
					i.value = 0;
					i.active = true;
					i.hide = 0;
				});
			}, 500);
		},

        onGotWinner: function () {
			BAWK.play('ui_popupclose');
            this.$parent.hide();
        },

		watchVideo() {
			if (this.watchAdClicked) {
				return;
			}

			this.watchAdClicked = true;
			vueApp.chwDoIncentivized();
			setTimeout(() => {
				this.watchAdClicked = false;
			}, 2000);
		},

		signIn() {
            this.$parent.hide();
			vueApp.onChwSignInClicked();
			vueApp.onSignInClicked();
		}
    },
	computed: {
		chwBarProgress() {
			return this.chw.progress + '%';
		},
		showAmountRewarded() {
			if (this.reward.eggs) {
				return `+${this.reward.eggs}`;
			}
		},

		rewardItem() {
			return this.reward.itemIds.length > 0 ? extern.catalog.findItemById(this.reward.itemIds[0]) : [];
		},

		txtState() {
			let t = {};

			if (!this.firebaseId) {
				t.desc = this.loc.chw_create_account;
				t.btn = this.loc.not_now;
			} else {
				if (this.eggGameReady) {
					t.desc = this.loc.p_nugget_instruction;
					t.btn = this.loc.p_nugget_button;
					if (this.busted) {
						t.desc = '';
					}
				} else {
					if (this.chw.winnerCounter > 3) {
						t.desc = this.loc.chw_daily_limit_msg_two;
						t.btn = this.loc.close;
					} else {
						t.desc = '';
						t.btn = this.loc.close;
					}
				}
			}

			return t;
		},

		limitReached() {
			return this.chw.winnerCounter > 3;
		},

		eggGameReady() {
			return ((this.reward.eggs || this.reward.itemIds.length > 0) && this.firebaseId && !this.limitReached);
		},

		showCountDown() {
			return (!(this.reward.eggs || this.reward.itemIds.length > 0) && this.firebaseId && !this.limitReached && !this.chw.ready);
		},

		showAdWatch() {
			return (!(this.reward.eggs || this.reward.itemIds.length > 0) && this.firebaseId && !this.limitReached && this.chw.ready);
		},

		showDescTxt() {
			return (!this.chw.ready && this.limitReached);
		},

		showPopupBtn() {
			return ((this.busted && (this.reward.eggs || this.reward.itemIds.length > 0)) || this.showCountDown || this.showAdWatch || this.limitReached || !this.firebaseId);
		},

		chickSrc() {
			if (this.limitReached || !this.firebaseId) {
				return this.chw.imgs.limit;
			}
			return this.chw.imgs.sleep;
		},

		rewardHasItem() {
			return this.reward.itemIds.length > 0 && !this.reward.eggs && this.busted;
		},
		
	},
	watch: {
		busted(val) {
			if (val) {
				BAWK.play('mini-egg-game_shellburst');
				setTimeout(() => {
					BAWK.play('mini-egg-game_victory');
				}, 500);
			}
		},
	}
};
</script><script id="social-panel-template" type="text/x-template">
	<div ref="socialMediaIcons" class="social_icons roundme_sm f_row gap-sm ss_margintop_xl fullwidth justify-content-end">
		<!-- <a :href="newsLetterUrl" target="_blank" @click="playSound('newYolker')">
			<div class="icon-wrap bg_blue3 roundme_sm">
				<span class="sr-only">Get the Shell Shocker's Newsletter: The New Yolker</span>
				<i aria-hidden="true" class="text_blue1 fas fa-envelope-open-text"></i>
			</div>
		</a> -->
		<!-- ['name', 'reward', 'url', 'img', 'icon'] -->
		<social-promo ref="socialIcons" v-for="(item, idx) in socialItems" :key="idx" :name="item.name" :reward="item.reward" :url="item.url" :img="item.imgPath" :icon="item.icon" :is-active="item.active" :loc="loc" :is-poki="isPoki" :use-social="socialMedia" :id="item.id"></social-promo>
		<!-- <social-promo ref="socialIcons" :name="showSocialMedia.name" :reward="showSocialMedia.reward" :url="showSocialMedia.url" :img="showSocialMedia.imgPath" :icon="showSocialMedia.icon" :is-active="showSocialMedia.active" :loc="loc" :is-poki="isPoki" :use-social="showSocialMedia.reward" :overlap="adOverlap"></social-promo> -->

	</div>
</script>
<script id="social-promo-template" type="text/x-template">
	<div class="social-media box_relative" :class="cls">
		<div v-if="isActive" class="tool-tip" :class="{'active' : isBubbleActive}">
			<a :href="url" target="_blank" :title="urlTitle" class="bg_blue4"  @click="onClickReward()">
				<div class="icon-wrap bg_blue3 f_row align-items-center justify-content-center roundme_sm text-center">
					<span class="sr-only">Vist Shell Shocker's {{ name }} page</span>
					<i aria-hidden="true" class="text_blue1" :class="useIcon"></i>
				</div>
			</a>
			<div class="tool-tip--bubble" v-show="bubbleHover">
				<div class="tool-tip--group display-grid grid-column-1-2">
					<div class="tool-tip--image box_relative">
						<img v-if="img" class="discord-bubble-img box_absolute" :src="imgSrc" :alt="imgAlt">
					</div>
					<div class="tool-tip--text text-left">
						<section v-html="socialDesc"></section>
					</div>
				</div>
				<!-- .tool-tip--group -->
			</div>
				<!-- .tool-tip--bubble -->
		</div>
		<!-- .tool-tip -->
		<a v-if="!isActive" :href="url" target="_blank" class="bg_blue4" @click="onClickReward()">
			<div class="icon-wrap bg_blue3 f_row align-items-center justify-content-center roundme_sm text-center">
				<span class="sr-only">Vist Shell Shocker's {{ name }} page</span>
				<i aria-hidden="true" class="text_blue1 fab" :class="useIcon"></i>
			</div>
		</a>
	</div>
</script>


<script>
var COMPSOCIALPROMO = {
	template: '#social-promo-template',
	props: ['name', 'reward', 'url', 'img', 'icon', 'loc', 'isPoki', 'useSocial', 'id'],
	data: function () {
		return {
			isBubbleActive: false,
			bubbleRepeat : '',
			bubbleHover: true,
			isActive: false,
			isItemOwned: false,
			inventoryCheck: 0
		}
	},
	mounted() {
		this.discordBubbleTimer();
	},
	methods: {
		playSound (label) {
			BAWK.play('ui_click');
		},
		discordBubbleTimer() {
			if (this.reward === this.useSocial) {
				if (extern.isGameReady) {
					this.inventoryCheck = 0;
					setTimeout(() => {
						this.isItemOwned = extern.isItemOwned({id: this.id});
						if (!this.isItemOwned) {
							this.isActive = true;
							this.bubbleRepeat = setInterval(() => {
                               this.isBubbleActive = this.isBubbleActive ? false : true;
                       		}, 3000);
						}
					}, 1000);
				} else {
					this.inventoryCheck++;
					if (this.inventoryCheck < 6 && !this.isActive) {
						setTimeout(() => this.discordBubbleTimer(), 2000);
					}
				}
			}
		},

		onClickReward() {
			if (!this.reward) return;
			this.gaSend(this.reward);

			if (!this.isItemOwned && this.reward) {
				extern.socialReward(this.reward);
			}
			this.playSound();
			this.isBubbleActive = false;
			this.bubbleHover = false;

			if (this.bubbleRepeat) {
				clearInterval(this.bubbleRepeat);
			}
		},
		gaSend(label) {
			if (!label) return;
            ga('send', 'event', 'social-buttons', 'click', label);
		}
	},
	computed: {
		itemRedeemed() {
			return localStore.getItem(this.reward + 'Rewarded');
		},
		urlTitle() {
			return `Blue Wizard ${this.name} page`;
		},
		imgAlt() {
			return `Join Blue Wizard's ${this.name} page`;
		},
		imgSrc() {
			return `img/social-media/${this.img}`;
		},
		socialDesc() {
			return this.loc['footer_social_media_' + this.name.toLowerCase()];
		},
		cls() {
			return this.useSocial === this.reward ? `active-social-${this.useSocial.toLowerCase()}` : '';
		},
		useIcon() {
			if (this.name == 'newYolker') {
				return `fas ${this.icon}`;
			} else {
				return `fab ${this.icon}`;
			}
		},
	},
	watch: {
		// useSocial(val) {
		// 	if (!val) {
		// 		return;
		// 	}
		// 	this.isActive = this.reward === val;
		// }
	}
};
</script><script>
var comp_social_panel = {
	template: '#social-panel-template',
	components: {
		'social-promo': COMPSOCIALPROMO
	},
	props: ['loc', 'isPoki', 'socialMedia', 'useSocial'],
	data: function () {
		return {
			// adOverlap: false,
			newsLetterUrl: 'https://bluewizard.com/subscribe-to-the-new-yolker/',
		}
	},
	computed: {
		// showSocialMedia() {
		// 	return this.useSocial[Math.floor(Math.random()*this.useSocial.length)];
		// },
		socialItems() {
			const idx = this.useSocial.findIndex(el => el.reward === this.socialMedia);
			if (idx >= 0) {
				const social = this.useSocial[idx]
				this.useSocial.splice(idx, 1);
				this.useSocial.push(social);
			}
			return this.useSocial;
		}
	}
};
</script><script id="chw-home-screen" type="text/x-template">
	<div id="chw-home-timer" ref="chw-home-timer" style="display: none" v-show="showChw" class="chw-home-timer display-grid grid-column-1-2 grid-align-items-center box_absolute grid-gap-1">
			<div class="box_relative">
				<img class="box_absolute chw-loot-img" src="img/chicken-nugget/chw-loot-btn.webp" />
				<img class="chw-home-timer-chick box_absolute" :src="chwChickSrc">
			</div>
			<div class="chw-bubble-wrap box_relative" :class="chwHomeTimerCls">
				<div class="display-grid grid-align-items-center bg_white chw-circular-timer-container box_relative gap-sm" :class="chwClass">
					<div v-show="!chw.onClick">
						<p class="chw-circular-timer-countdown nospace text-center">
							<span class="chw-pie-remaining text-center chw-msg chw-r-msg" v-html="remainingMsg"></span>
							<br />
							<span v-show="!chw.ready && !chw.adBlockDetect"><span v-show="chw.hours" class="chw-pie-num">{{chw.hours}}:</span><span v-show="chwShowTimer" class="chw-pie-num">{{chw.minutes}}:</span><span v-show="chwShowTimer" class="chw-pie-num">{{chw.seconds}}</span></span>
						</p>
						<button v-if="chwShowBtn" class="ss_button btn_sm btn_yolk bevel_yolk" :class="btnStyle" @click="playIncentivizedAd" v-html="playAdText"><icon v-show="chw.winnerCounter" name="ico_watchAd" class="chw-icon-watch-ads"></icon></button>
					</div>
				</div>
				<div class="speech-tail"></div>
				<div class="chw-circular-timer-container-shadow"></div>
			</div>
		</div>
		<!-- .chw-timer -->
</script>

<script>
const CompChwHomeScreen = {
	template: '#chw-home-screen',
	props: ['loc', 'screens', 'currentScreen', 'ui', 'chw', 'firebaseId'],
	data: function () {
		return {}
    },
	methods: {
		playIncentivizedAd() {
			vueApp.playIncentivizedAd();
		}
	},
	computed: {
		remainingMsg() {
			if (this.chw.adBlockDetect) {
				return 'Please turn off ad blocker';
			}

			if (this.isChicknWinnerError) {
				return this.loc.chw_error_text;
			}

			if (this.chw.limitReached && !this.chw.ready) {
				return this.loc.chw_daily_limit_msg;
			}

			if (this.chw.ready) {
				return this.chw.winnerCounter > 0 ? this.loc.chw_cooldown_msg : this.loc.chw_ready_msg;
			}

			return this.loc.chw_time_until;
		},
		chwHomeTimerCls() {
			if (this.chw.limitReached) {
				return 'chw-home-screen-max-watched';
			} else {
				if (this.chw.ready) {
					return 'is-ready active';
				} else {
					return 'not-ready';
				}
			}
		},
		chwClass() {
			if (this.chw.limitReached || this.isChicknWinnerError) {
				return 'grid-column-1-eq';
			} else {
					return 'grid-column-1-eq';
			}
		},
		chwChickSrc() {
			if (this.chw.limitReached || this.isChicknWinnerError) {
				// return 'img/chicken-nugget/chickLoop_daily_limit.svg';
				return this.chw.imgs.limit;
			} else {
				if (!this.chw.ready) {
					// return 'img/chicken-nugget/chickLoop_sleep.svg';
					return this.chw.imgs.sleep;
				} else {
					// return 'img/chicken-nugget/chickLoop_speak.svg';
					return this.chw.imgs.speak;
				}
			}
		},
		chwShowTimer() {
			return true;
			if (this.chw.limitReached) {
				// this.chwStopCycle();
				return false;
			} else {
				if (this.chw.ready) {
					this.chwShowCycle();
					return false;
				} else {
					// this.chwStopCycle();
					return true;
				}
			}
		},
		chwShowBtn() {
			if ((this.chw.ready && !this.chw.limitReached && !this.chw.adBlockDetect) || (!this.chw.ready && this.chw.limitReached && !this.chw.adBlockDetect)) {
				return true;
			} else {
				return false;

			}
		},
		playAdText() {
			if (this.chw.limitReached) {
				return this.loc.chw_wake.format(200 * (this.chw.resets + 1));
			} else {
				return this.loc.chw_btn_free_reward;
			}
		},
		btnStyle() {
			if (this.chw.limitReached) {
				return 'chw-limit-reached';
			}
		},
		showChw() {
			return this.firebaseId && this.ui.showHomeEquipUi;
		},
	}
};
</script>
<script id="home-screen-template" type="text/x-template">
	<div>
		<div class="twitch-btn-wrap box_absolute">
			<button v-if="ui.events.twitch && !extern.inGame" class="ss_button twitch-btn btn_sm box_relative text-right" @click="onTwitchDropsClick">Twitch Drops Live!<span class="twitch-btn-status" v-html="isTwitchLinked"></span> <img class="box_absolute" src="img/twitch-drops/twitch-drops-parachute.svg" alt=""></button>
		</div>

		<house-ad-big id="big-house-ad" ref="bigHouseAd" :useAd="ui.houseAds.big" @big-house-ad-closed="onBigHouseAdClosed"></house-ad-big>
		<div id="display-ad-header-home" ref="displayAdHeader">
			<display-ad id="shellshock-io_728x90_HP_wrap" ref="headerDisplayAd" class="display-ad-header centered_x" :ignoreSize="true" :adUnit="displayAd.adUnit.header" adSize="468x60" :check-products="checkProducts"></display-ad>
		</div>

		<!-- <gauge-meter v-show="showScreen !== screens.profile" ref="gaugeMeter" @gauge-meter-click="onGaugeMeterClick"></gauge-meter> -->
		<div class="homescreen-main-wrapper display-grid">
			<div class="box_relative fullwidth">
				<profile-screen id="profileScreen" ref="profileScreen" :loc="loc" :claimed="challengesClaimed" v-show="(showScreen === screens.profile)" @leave-game-confimed="leaveGameConfirmed"></profile-screen>
				<play-panel id="play_game" ref="playPanel" v-show="showScreen === screens.home" :show-screen="showScreen" :screens="screens" :loc="loc" :player-name="playerName" :game-types="gameTypes" :current-game-type="currentGameType" :is-game-ready='accountSettled' :region-list="regionList" :current-region-id="currentRegionId" :home="home" :play-clicked="playClicked" :current-class="classIdx" :language-code="currentLanguageCode" @playerNameChanged="onPlayerNameChanged" @game-type-changed="onGameTypeChanged" :maps="maps"></play-panel>
			</div>
			<aside class="secondary-aside box_relative display-grid justify-content-end">
				<div class="secondary-aside-wrap box_relative">					
					<media-tabs ref="mediaTabs" :loc="loc" :newsfeedItems="newsfeedItems" :twitchStreams="twitchStreams" :youtubeStreams="youtubeStreams" :challenges="player.challenges" :challenge-daily-data="player.challengeDailyData" :firebase-id="firebaseId" @chlgReroll="challengeReroll"></media-tabs>
					<display-ad id="shellshockers_titlescreen_wrap" ref="titleScreenDisplayAd" class="house-small box_absolute" :ignoreSize="true" :adUnit="displayAd.adUnit.home" adSize="300x250" :check-products="checkProducts"></display-ad>
				</div>
			</aside>
			<!-- <house-ad-small id="banner-ad" :useAd="ui.houseAds.small"></house-ad-small> -->
		</div>
		<div id="mainFooter" class="centered_x">
			<!-- <chicken-panel ref="chickenPanel" id="chicken_panel" :local="loc" :do-upgraded="isUpgraded"></chicken-panel> -->
			<section>
				<footer-links-panel id="footer_links_panel" :loc="loc" :version="changelog.version" :is-poki="isPoki"></footer-links-panel>
			</section>
		</div>

		<!-- Popup: Check Email -->
		<small-popup id="checkEmailPopup" ref="checkEmailPopup" :hide-cancel="true">
			<template slot="header">{{ loc.p_check_email_title }}</template>
			<template slot="content">
				<p>{{ loc.p_check_email_text1 }}:</p>
				<h5 class="nospace text-center">{{ maskedEmail }}</h5>
				<p class="ss_marginbottom">{{ loc.p_check_email_text2 }}</p>
			</template>
			<template slot="confirm">{{ loc.ok }}</template>
		</small-popup>

		<!-- Popup: Resend Email -->
		<small-popup id="resendEmailPopup" ref="resendEmailPopup" @popup-confirm="onResendEmailClicked" @popup-x="onHideResendEmail" @popup-cancel="onHideResendEmail">
			<template slot="header">{{ loc.p_resend_email_title }}</template>
			<template slot="content">
				<p>{{ loc.p_resend_email_text1 }}:</p>
				<h5 class="nospace text-center">{{ maskedEmail }}</h5>
				<p class="ss_marginbottom">{{ loc.p_resend_email_text2 }}</p>
			</template>
			<template slot="cancel">{{ loc.ok }}</template>
			<template slot="confirm">{{ loc.p_resend_email_resend }}</template>
		</small-popup>

		<small-popup id="resendEmailConfirm" ref="resendEmailConfirm" :hide-cancel="true" @popup-closed="onHideResendEmail">
			<template slot="header">{{ loc.verify_email_sent }}</template>
			<template slot="content">
				<!-- content not loc'd (yet) -->
				{{ loc.verify_email_instr }}
			</template>
			<template slot="confirm">{{ loc.close }}</template>
		</small-popup>

		<!-- <large-popup id="hvsmPopup" ref="hvsmPopup" @popup-closed="onHvsmPopupClose" @popup-opened="onHvsmPopupOpen" @popup-x="onHvsmPopupClose">
			<template slot="content">
				<div id="hvsm-popup-item-grid-wrap" class="hvsm-popup-item-grid-wrap paddings_lg display-grid gap-1 grid-column-3-eq">
					<div class="hvsm-popup-item-grid hvsm-popup-heroes-column">
						<header>
							<img class="display-block center_h" :src="hvsm.hero.img" alt="Heroes logo">
							<h3 class="text-center text-uppercase text_blue5">{{ hvsm.hero.name }}</h3>
						</header>
						<div id="equip_grid" class="center_h f_row align-content-start align-content-start gap-sm">
							<item v-for="(item, idx) in hvsm.hero.items" :loc="loc" :item="item" :key="item.id" @item-selected="onHvsmClicked" :is-shop="false"></item>
						</div>
						<button class="ss_button btn_md btn_yolk bevel_yolk fullwidth" @click="onHvsmClicked(hvsm.hero.name)">
							Hero Items
						</button>
					</div>
					<div class="hvsm-popup-desc">
						<header>
							<h1 class="nospace text_white text-shadow-black-40 text-center">Egg Org &#38; Eggventure</h1>	
						</header>
						<p class="text_blue5">
							Welcome brave Eggventurers, to a tale of mystery, magic, & mayhem! 
						</p>
						<p class="text_blue5">
							Equip your skins of choice to choose your side. Each kill with an equipped Monsters or Heroes item will bring your side closer to victory! Who will win to unlock an item for all? You decide. 
						</p>
						<p class="text_blue5">
							Grab your swords & prepare yourshellves, for the eggventure of a lifetime awaits!
						</p>
					</div>
					<div class="hvsm-popup-item-grid hvsm-popup-monsters-column">
						<header>
							<img class="display-block center_h" :src="hvsm.monster.img" alt="Monsters logo">
							<h3 class="text-center text-uppercase text_blue5">{{ hvsm.monster.name }}</h3>
						</header>
						<div id="equip_grid" class="center_h f_row align-content-start align-content-start gap-sm">
							<item v-for="(item, idx) in hvsm.monster.items" :loc="loc" :item="item" :key="item.id" @item-selected="onHvsmClicked" :is-shop="false"></item>
						</div>
						<button class="ss_button btn_md btn_yolk bevel_yolk fullwidth" @click="onHvsmClicked(hvsm.monster.name)">
							Monster Items
						</button>
					</div>
				</div>
			</template>
		</large-popup> -->
		
	</div>
</script>

<script id="create-private-game-template" type="text/x-template">
    <div>
        <div class="roundme_sm fullwidth">
            <div>
                <div class="create-game-map-select display-grid">
					<h1 class="create-game-header roundme_sm text-center">
						{{ loc.p_privatematch_title }}
					</h1>
					<div class="create-game-map-search box_relative">
						<!-- <input ref="mapSearch" name="name" v-bind:placeholder="loc.p_privatematch_find_map" v-on:keyup="onMapSerachKeyup($event)" class="ss_field font-nunito box_relative"> -->
						<div class="box_relative display-grid grid-column-auto-1 gap-sm">
							<div class="box_relative">
								<label for="search-map" class="centered_y"><i class="fas fa-search text_blue3" :class="[mapSearchResults.length || mapNotFound ? 'fa-times-circle' : 'fa-search']" @click="onMapSearchReset"></i></label>
								<input ref="mapSearch" name="search-map" v-bind:placeholder="loc.p_privatematch_find_map" v-on:keyup="onMapSerachKeyup($event)" @blur="onBlurSearhFocus" class="ss_field font-nunito box_relative fullwidth">
							</div>
							<button class="ss_button btn_blue bevel_blue box_relative text-shadow-none create-game-map-btn-random" @click="onRandomMapClick"><i class="fas fa-random"></i></button>
						</div>
						<div v-show="mapSearchResultsShow" class="option-box box_absolute roundme_sm common-box-shadow bg_blue6 pos-right">
							<ul class="list-no-style nospace ss-dropdown-select f_col">
								<li v-show="!mapSearchResults.length" class="text_blue5 font-nunito" @click="onMapSearchReset">{{ loc.p_privatematch_map_not_found }}</li>
								<li v-for="(item, idx) in mapSearchResults" :key="idx" @click="onMapSearchResultClick(item)" class="text_blue5 font-nunito">
									{{ item.name }}
								</li>
							</ul>
						</div>
					</div>
                    <div id="private_maps" class="roundme_md" :style="{ backgroundImage: 'url(' + mapImgPath + ')' }">
	                    <!-- <img :src="mapImgPath" id="mapThumb" class="roundme_sm text-center"> -->
	                    <div id="mapNav">
	                    	<button id="mapLeft" @click="onMapChange(-1)" class="clickme map-arrows text_white"><i class="fas fa-caret-left fa-3x"></i></button>
		                    <h5 id="mapText" class="text-shadow-black-40">
                                {{ mapList[mapIdx].name }}
                                <span class="map_playercount text-shadow-black-40 font-nunito box_absolute">
									<icon class="map-avg-size-icon fill-white shadow-filter" :name="mapSizeIcon"></icon>
                                </span>
                            </h5>
							<button id="mapRight" @click="onMapChange(1)" class="clickme map-arrows text_white"><i class="fas fa-caret-right fa-3x"></i></button>
	                    </div>
                    </div>
					<div class="hideme">{{ currentRegionId }}</div>
					<ss-button-dropdown class="btn-1 fullwidth" :loc="loc" :loc-txt="gameTypeTxt" :list-items="gameTypes" :selected-item="pickedGameType" menuPos="right" @onListItemClick="onGameTypeChange"></ss-button-dropdown>
					<!-- <ss-button-dropdown :loc="loc" :loc-txt="mapTxt" :list-items="gameTypeMapList" :selected-item="mapIdx" @onListItemClick="onMapChangeClick"></ss-button-dropdown> -->
					<!-- <ss-button-dropdown class="btn-2 fullwidth" :loc="loc" :loc-txt="serverTxt" :list-items="regions" :selected-item="currentRegionId" menuPos="right" @onListItemClick="onServerChange"></ss-button-dropdown> -->
					<ss-button-dropdown class="play-panel-region-select btn-2 fullwidth" :loc="loc" :loc-txt="serverTxt"  :selected-item="currentRegionId" @onListItemClick="onServerChange" menuPos="right">
						<template slot="dropdown">
							<li v-if="regions" ref="items" v-for="(g, idx) in regions" :class="{ 'selected' : currentRegionId === g.id }" class="display-grid gap-1 align-items-center text_blue5 font-nunito regions-select" @click="onServerChange(g.id)">
								<div class="f_row align-items-center">
									<icon v-show="currentRegionId === g.id" name="ico-checkmark" class="option-box-checkmark"></icon>
								</div>
								<div>
									{{ loc[g.locKey ]}}
								</div>
								<div class="text-right">
									{{ g.ping }}ms
								</div>
							</li>
						</template>
					</ss-button-dropdown>
					<!-- <button class="ss_button button_blue bevel_blue fullwidth" @click="onServerClick">{{ loc.server }}: {{ loc[serverLocKey] }}</button> -->
					<button name="play" @click="onPlayClick" class="btn-3 f_row align-items-center gap-sm is-for-play ss_button btn_md text-uppercase font-sigmar fullwidth btn_green bevel_green margin-0">{{ loc.p_privatematch_button }} <icon class="fill-white shadow-filter" name="ico-backToGame"></icon></button>
                </div>
            </div>
        </div>
    </div>
</script>

<script>
var comp_create_private_game_popup = {
    template: '#create-private-game-template',
    props: ['loc', 'regionLocKey', 'mapImgBasePath', 'isGameReady', 'gameTypeTxt', 'mapList', 'regions', 'currentRegionId',  'gameTypes', 'pickedGameType'],

	mounted() {
		this.randomMap();
	},
    
    data: function () {
        return {
            showingRegionList: false,
            mapIdx: 0,
            playClickedBeforeReady: false,
			map: '',
            mapLocKey: '',
            mapImgPath: '',
			mapNotFound: false,
			mapSearchResults: [],
			mapSearchResultsIdx: 0,
			mapSearchResultsMax: 5,
			mapSearchResultsMin: 0,
			mapSearchResultsShow: false,
			mapSearchIsFocused: false,
			mapKeyListners: '',
            vueData,
        }
    },

    methods: {
		randomMap() {
			this.mapIdx = Math.randomInt(0, this.mapList.length);
			this.map = this.mapList[this.mapIdx];
			this.mapLocKey = this.map.locKey;
			this.mapImgPath = this.mapImgBasePath + this.map.filename + '.png?' + this.map.hash;
		},
		onRandomMapClick() {
			BAWK.play('ui_onchange');
			this.selectMapForPickedGameType('', true);
		},
        playSound (sound) {
			BAWK.play(sound);
        },
        
		onCloseClick: function () {
            this.$parent.close();
            BAWK.play('ui_popupclose');
        },
        
        onRegionChanged: function () {
            this.showingRegionList = true;
            this.$parent.toggle();
            vueApp.$refs.homeScreen.$refs.playPanel.$refs.pickRegionPopup.toggle();
            BAWK.play('ui_click');
        },

        onMapChange: function (dir) {
            this.selectMapForPickedGameType(dir);
            BAWK.play('ui_onchange');
        },

        selectMapForPickedGameType (dir, rnd) {
			let idx = this.mapIdx;

			let gameTypeShortName;

			for (var i = 0; i < vueData.maps.length; i++) { // Prevent race condition
				if (dir) idx = (idx + dir + vueData.maps.length) % vueData.maps.length;
				if (rnd) idx = Math.randomInt(0, vueData.maps.length);
				let map = vueData.maps[idx];
				gameTypeShortName = vueData.gameTypeKeys[this.pickedGameType];            

				if (map.modes[gameTypeShortName]) {
					break;
				}
				if (dir == 0) dir = 1
				//idx = (idx + dir + vueData.maps.length) % vueData.maps.length;
			}

			console.log('Random map deets: ', gameTypeShortName, vueData.maps[idx].modes[gameTypeShortName]);

			this.mapImgPath = this.mapImgBasePath + vueData.maps[idx].filename + '.png?' + vueData.maps[idx].hash;
			this.mapLocKey = vueData.maps[idx].locKey;
			this.mapIdx = idx;
        },

		onKeyDownMapSelect() {
			document.addEventListener('keydown', this.handleKeydown, true);
		},

		handleKeydown(e) {
			const keyName = e.key;
			switch (keyName) {
				case 'ArrowRight':
					this.onMapChange(1);
					break;
				case 'ArrowLeft':
					this.onMapChange(-1);
					break;
				case 'ArrowDown':
				case 'ArrowUp':
					if (this.mapSearchIsFocused) return;
					this.mapSearchIsFocused = true;
					this.$refs.mapSearch.focus();			
				default:
					break;
			}

		},

		removeKeydown() {
			this.mapSearchIsFocused = false;
			document.removeEventListener('keydown', this.handleKeydown, true);
		},

        onGameTypeChanged () {
            BAWK.play('ui_onchange');
            this.selectMapForPickedGameType(0);
        },

		onPlayTypeWhenSignInComplete() {
			return this.playClickFunction();
		},
		onPlaySentBeforeSignIn() {
			this.gameClickedBeforeReady = true;
			vueApp.showSpinner('signin_auth_title', 'signin_auth_msg');
		},
        onPlayClick: function () {
			this.removeKeydown();
            this.$parent.close();
            if (!this.isGameReady) {
                this.onPlaySentBeforeSignIn();
                return;
            }
            vueApp.externPlayObject(vueData.playTypes.createPrivate, this.pickedGameType, this.vueData.playerName, this.mapIdx, '');
            BAWK.play('ui_playconfirm');
        },
		onGameTypeChange(val) {
			// Not using a select here because it's not possible to style it so we have to update the game mode
			// manually. This is a bit of a hack but it works.
			this.pickedGameType = val;
			// Minor change here. Sending the game type to update global game type change this if we want.
			this.$emit('onGameTypeChange', this.pickedGameType);
			this.selectMapForPickedGameType(0);
		},
		onMapChangeClick(idx) {
			if (idx >= 0) {
				for (var i = 0; i < this.mapList.length; i++) { // Prevent race condition
					let map = this.mapList[idx];
					let gameTypeShortName = vueData.gameTypeKeys[this.pickedGameType];            

					if (map.modes[gameTypeShortName]) {
						break;
					}
				}
				this.mapImgPath = this.mapImgBasePath + this.mapList[idx].filename + '.png?' + this.mapList[idx].hash;
				this.mapLocKey = this.mapList[idx].locKey;
				this.mapIdx = idx;
				BAWK.play('ui_onchange');
			}
		},
		onServerChange(val) {
			this.$emit('onRegionPicked', val);
		},
		onMapSerachKeyup(e) {
			if (this.$refs.mapSearch.value.length >= 1) {
				this.mapSearchResultsShow = true;
				this.mapSearchResults = this.mapList.filter((map, idx) => {
					if (map.name.toLowerCase().replace(/[^a-zA-Z ]/g, "").startsWith(this.$refs.mapSearch.value.toLowerCase())) {
						if (map.modes[vueData.gameTypeKeys[this.pickedGameType]]) {
							if (!this.mapSearchResults.some(map => idx === map.id)) {
								return true;
							}
							return false;
						}
					} else {
						return false;
					}
				});
				if (!this.mapSearchResults.length) {
					this.mapNotFound = true;
				}
			} else {
				this.mapSearchResults.length = 0;
				this.mapSearchResultsShow = false;
				this.mapNotFound = false;
			}

			if (this.mapSearchResults.length === 1) {
				this.onMapChangeClick(this.mapList.findIndex(m => m.filename === this.mapSearchResults[0].filename));
				this.mapSearchResultsShow = false;
				this.mapNotFound = false;
			}
		},
		onMapSearchReset() {
			this.$refs.mapSearch.value = '';
			this.mapSearchResultsShow = false;
			this.mapSearchResults.length = 0;
			this.mapNotFound = false;
			this.mapSearchIsFocused = false;
		},
		onMapSearchResultClick(map) {
			this.onMapSearchReset();
			this.onMapChangeClick(this.mapList.findIndex(m => m.filename === map.filename));
		},
		onBlurSearhFocus() {
			this.mapSearchIsFocused = false;
		}
    },
	computed: {
		serverTxt() {
				let name = '';
				if (hasValue(this.regions) && hasValue(this.currentRegionId)) {
					name = this.regions.filter(s => s.id === this.currentRegionId)[0].locKey;
				}
			return {
				title: this.loc.p_servers_title,
				subTitle: this.loc[name]
			}
		},
		mapSizeIcon() {
			if (this.mapList[this.mapIdx].numPlayers <= 13) {
				return 'ico-map-size-small';
			} else if (this.mapList[this.mapIdx].numPlayers >= 14 && this.mapList[this.mapIdx].numPlayers <= 17) {
				return 'ico-map-size-med';
			} else if (this.mapList[this.mapIdx].numPlayers > 17) {
				return 'ico-map-size-large';
			}
		}
	},
    watch: {
        isGameReady(val) {
            if (this.gameClickedBeforeReady && val) {
                setTimeout(() => this.onPlayClick(), 700);
            }
        }
	}   
};
</script><script id="account-panel-template" type="text/x-template">
	<div>
		<div id="account_top" class="f_row f_end_only account-wrapper align-items-center ">
			<event-panel v-show="showCornerButtons" :current-screen="currentScreen" :screens="screens"></event-panel>
			<!-- <eggstore-notify ref="shirtStore" :show="showCornerButtons" :loc="loc" :sku="sku" icon="fa-tshirt" :text-hide="true" text="p_egg_shop_sale_notify" title="account_threadless" color="blue" url="https://bluewizard.threadless.com/" analytics="threadless"></eggstore-notify> -->
			<!-- <eggstore-notify ref="eggStoreSaleNotify" :text-hide="!hideNewItemNotify" :show="showCornerButtons" :loc="loc" :sku="sku" title="account_premium_item" icon="fa-gem" text="p_egg_shop_sale_notify" analytics="diamond"></eggstore-notify> -->
			<div class="account_eggs roundme_sm clickme f_row align-items-center" @click="onEggStoreClick" v-bind:title="loc['account_title_eggshop']">
				<div class="box_relative">
					<img :src="isAnonymous ? 'img/svg/ico_goldenEgg_callout.svg' : 'img/svg/ico_goldenEgg.svg'" class="egg_icon">
				</div>
				<span ref="eggCounter" class="egg_count">{{ eggBalance }}</span>
			</div>
			<!-- <button v-if="showVipButton" @click="onSubscriptionClick" class="ss_button btn_yolk bevel_yolk btn_vip" :title="loc['account_vip']" :class="{'has-sub' : isVipLive}"><img src="img/vip-club/vip-club-emblem-sm.webp" alt="VIP Emblem"> {{vipButtonText}}</button> -->
			<button v-show="showNotInGame" :class="accountBtnCls" @click="onAccountBtnClick" class="ss_button btn-account-status font-sigmar align-items-center text-center justify-content-center">
				<span v-if="!isNotSignedIn">
					<icon name="ico-vip"></icon>
				</span> {{ accountBtnText }}
			</button>
			<!-- <input type="image" src="img/ico_nav_leaderboards.webp" class="account_icon roundme_sm"> -->
			<div id="corner-buttons" v-show="showCornerButtons" class="f_row f_end_only align-items-center ">
				<button v-if="isPrivateGame && !showNotInGame" class="ss_button btn_blue bevel_blue box_relative pause-screen-ui btn-account-w-icon text-shadow-none text_blue1" @click="onGameOptionsClick" :title="loc.p_privateoptions_button">
					<!-- <img class="icon-md" src="img/svg-icons/ico-private-game-config.svg"> -->
					<icon name="ico-private-game-config" class="icon-md svg-icon"></icon>
				</button>
				<!-- <input type="image" src="img/ico_nav_shop.webp" @click="itemStoreClick" class="account_icon roundme_sm" v-bind:title="loc['account_title_shop']"> -->
				<!-- <input type="image" src="img/ico_nav_help.webp" @click="onHelpClick" class="account_icon roundme_sm" v-bind:title="loc['account_title_faq']"> -->
				<button @click="onTutorialClicked" v-show="currentScreen === screens.game" class="ss_button btn_blue bevel_blue box_relative pause-screen-ui btn-account-w-icon text-shadow-none text_blue1" :title="loc.tutorial_title"><i class="fas fa-question"></i></button>
				<button @click="onShareLinkClick" v-show="showShareLinkButton"  class="ss_button btn_blue bevel_blue box_relative pause-screen-ui btn-account-w-icon text-shadow-none text_blue1" :title="loc.p_pause_sharelink"><i :class="vueData.icon.invite"></i></button>
				<button @click="onSettingsClick" class="ss_button btn_blue bevel_blue box_relative pause-screen-ui btn-account-w-icon text-shadow-none text_blue1" :title="loc.account_title_settings"><i :class="vueData.icon.settings"></i></button>
				<button @click="onFullscreenClick" v-if="isCrazyGames" class="ss_button btn_blue bevel_blue box_relative pause-screen-ui btn-account-w-icon text-shadow-none text_blue1" :title="loc.account_title_fullscreen"><icon name="ico-fullscreen" class="btn-fullscreen"></icon></button>
			</div>
		</div>
		
		<!-- <div id="account_bottom" v-show="showBottom">
			<language-selector :languages="languages" :loc="loc" :selectedLanguageCode="selectedLanguageCode" :langOptions="currentLangOptions"></language-selector>
			<button id="signInButton" v-show="(isAnonymous && showSignIn)" @click="onSignInClicked" class="ss_button btn_yolk bevel_yolk">{{ loc.sign_in }}</button>
			<button id="signOutButton" v-show="!isAnonymous" @click="onSignOutClicked" class="ss_button btn_yolk bevel_yolk">{{ loc.sign_out }}</button>
			<div id="player_photo" class="box_relative" v-show="photoUrl !== null && photoUrl !== undefined && photoUrl !== '' && ! isAnonymous">
				<img :src="photoUrl" class="roundme_sm bevel_blue"/>
				<div v-if="isTwitch" class="box_absolute account-panel-twitch roundme_sm" @click="onTwitchIconClick"><i class="fab fa-twitch"></i></div>
			</div>
		</div> -->
	</div>

</script>
<template id="egg-store-notify">
    <div v-if="show" class="egg-store-sale-notify" :class="{'white-blue' : color}" @click="notifyClick">
        <button class="account_icon roundme_sm account_icon-item" :title="getTitle"><i aria-hidden="true" class="fas" :class="icon"><span class="hideme">Egg</span></i>
           <span class="text" :class="{hideme : textHide}"> {{loc[text]}}</span>
        </button>
    </div>
</template>
<script>
    const compEggStoreSaleNotify = {
        template: '#egg-store-notify',
        props: ['loc', 'show', 'sku', 'textHide', 'text', 'icon', 'color', 'url', 'title', 'analytics'],
        methods: {
            notifyClick() {
                if (this.analytics) ga('send', 'event', 'header-buttons', 'click', this.analytics);

                if (this.url) {
                    window.open(this.url, '_window');
                    return;
                }

                // if (!vueData.firebaseId) {
				//     vueApp.showGenericPopup('p_redeem_error_no_player_title', 'p_redeem_error_no_player_content', 'ok');
				//     return;
                // }

                vueApp.eggStoreReferral = 'Sale notify ref';

                if (this.sku) {
                    return vueApp.showPopupEggStoreSingle(this.sku)
                }

                return vueApp.onPremiumItemsClicked();
            }
        },
        computed: {
            getTitle() {
                if (!this.title) return null;
                return this.loc[this.title];
            }
        }
    };
</script><script>
var comp_account_panel = {
	template: '#account-panel-template',
	components: {
		'language-selector': comp_language_selector,
		'eggstore-notify': compEggStoreSaleNotify,
		'event-panel': comp_events,
	},

	props: ['loc', 'eggs', 'languages', 'selectedLanguageCode', 'isPaused', 'photoUrl', 'isAnonymous', 'isOfAge', 'showTargetedAds', 'showCornerButtons', 'ui', 'isEggStoreSale', 'sku', 'isSubscriber', 'isTwitch', 'currentLangOptions', 'currentScreen', 'screens', 'isPrivateGame'],

	
	data: function () {
		return {
			languageCode: this.selectedLanguageCode,
			eggBalance: 0,
			vueData,
		}
	},

	created() {
		this.getEggsLocalStorage();
	},
	methods: {
		getEggsLocalStorage() {
			const raw = localStore.getItem('localLoadOut');
			if (!raw) {
				return;
			}
			const storage = JSON.parse(raw);
			if (!'balance' in storage) {
				return;
			}
			return this.eggBalance = storage.balance;

		},
		onEggStoreClick: function () {
			if (vueData.showAdBlockerVideoAd) {
				return;
			}
			if (!vueData.firebaseId) {
				vueApp.showGenericPopup('p_redeem_error_no_player_title', 'p_redeem_error_no_player_content', 'ok');
				return;
			}
			vueApp.openEquipSwitchTo(vueApp.equipMode.shop)
			BAWK.play('ui_popupopen');
			this.gaSend('eggCount');
		},
		itemStoreClick: function() {
			this.gaSend('openItemShop');
			vueApp.openEquipSwitchTo();
			vueApp.$refs.equipScreen.switchToShop();
			BAWK.play('ui_popupopen');
		},
		onHelpClick: function () {
			vueApp.showHelpPopup();
			this.gaSend('openHelp');
			BAWK.play('ui_popupopen');
		},

		onSettingsClick: function () {
			this.gaSend('openSettings');
			this.onSharedPopupOpen();
			vueApp.showSettingsPopup();
			BAWK.play('ui_popupopen');
		},

		onTutorialClicked() {
			this.gaSend('openTutorial');
			vueApp.onTutorialPopupClick();
			BAWK.play('ui_popupopen');
		},

		onFullscreenClick: function () {
			this.gaSend('fullscreen');
			extern.toggleFullscreen();
			BAWK.play('ui_click');
		},

		onSignInClicked: function () {
			vueApp.setDarkOverlay(true);
			this.$emit('sign-in-clicked');
		},

		onSignOutClicked: function () {
			vueApp.setDarkOverlay(true);
			this.$emit('sign-out-clicked');
		},

		onShareLinkClick: function () {
			this.gaSend('openShareLink');
			this.onSharedPopupOpen();
            extern.inviteFriends();
		},

		onAnonWarningClick: function() {
			ga('send', 'event', vueApp.googleAnalytics.cat.playerStats, vueApp.googleAnalytics.action.anonymousPopupOpen);
			vueApp.showAttentionPopup();
		},
		onSubscriptionClick() {
			this.gaSend('openVipPopup');
			vueApp.showSubStorePopup();
		},
		gaSend(label) {
			if (!label) return;
            ga('send', 'event', 'header-buttons', 'click', label);
		},
		onTwitchIconClick() {
			window.open(dynamicContentPrefix + 'twitch');
		},
		onAccountBtnClick() {
			if (this.isAnonymous && this.showSignIn) {
				this.onSignInClicked();
			} else {
				this.onSubscriptionClick();
			}
		},
		eggShake() {
			this.$refs.eggCounter.classList.add('egg-shake');
			setTimeout(() => this.$refs.eggCounter.classList.remove('egg-shake'), 300);
		},
		onSharedPopupOpen() {
			// if (extern.inGame) {
			// 	vueApp.hideRespawnDisplayAd();
			// }
		},
		onGameOptionsClick() {
			ga('send', 'event', 'respawn-popup', 'click', 'gameOptions');
			vueApp.onGameOptionsClick();
		},
	},

	computed: {
		showSignIn: function () {
			if (!isFromEU) {
				return true;
			}

			return isFromEU && this.isOfAge && this.showTargetedAds;
		},

		showShareLinkButton: function () {
			return this.showCornerButtons && this.currentScreen === this.screens.game;
		},

		hideNewItemNotify() {
			// if (!ssChangelogDate) return false;
			// if (!this.showCornerButtons) return false;
			// const lapsed = Date.now() - ssChangelogDate.valueOf(),
			// 	  days = Math.floor((lapsed / (60*60*24*1000)));

			// if (days <= 5 ) return true;
			// return false;
			return;
		},

		vipButtonText() {
			return this.isSubscriber && !extern.account.upgradeIsExpired ? '' : this.loc.s_btn_txt_subscribe;
		},
		showVipButton() {
			return this.showScreen === this.screens.home || this.showScreen === this.screens.equip;
		},
		isVipLive() {
			return this.isSubscriber && !extern.account.upgradeIsExpired;
		},
		accountBtnCls() {
			if (this.isAnonymous && this.showSignIn) {
				return 'btn_green bevel_green'
			} else {
				if (this.isSubscriber) {
					return 'btn_yolk bevel_yolk btn_vip width-auto vertical-align-middle';
				} else {
					return 'btn_yolk bevel_yolk btn_vip vertical-align-middle';
				}
			}

		},
		accountBtnText() {
			if (this.isAnonymous && this.showSignIn) {
				return this.loc.sign_in;
			} else {
				if (this.isSubscriber) {
					return '';
				} else {
					return this.loc.s_btn_txt_subscribe;
				}
			}
		},
		isNotSignedIn() {
			return this.isAnonymous && this.showSignIn;
		},

		showNotInGame() {
			return this.currentScreen !== this.screens.game && !extern.inGame
		},

		isGameOwner() {
			return extern.isGameOwner;
		},

		isCrazyGames() {
			return !crazyGamesActive;
		},
	},
	watch: {
		eggs() {
			this.eggShake();
			this.eggBalance = this.eggs;
		},
	}
};
</script>
<script id="play-panel-template" type="text/x-template">
	<div id="play-panel" class="box_relative">
		<weapon-select-panel id="weapon_select" class="justify-content-center centered_x" :loc="loc" :account-settled="isGameReady" :current-class="currentClass" :current-screen="showScreen" :screens="screens" :play-clicked="playClicked" @changed-class="onChangedClass"></weapon-select-panel>
		<div class="play-panel-btn-group display-grid grid-auto-flow-column gap-1 centered_x">
			<button @click="onJoinPrivateGameClick" class="is-for-play ss_button btn_big btn_blue_light bevel_blue_light btn_play_w_friends display-grid align-items-center box_relative">
				<!-- <img src="img/svg/ico_star_gold.svg" class="icon-star top-left"/> -->
				<span>{{ loc.p_privatematch_friends }}</span>
			</button>
			<button @click="onPlayButtonClick" class="is-for-play ss_button btn_big btn_green bevel_green play-button box_relative" v-html="playBtn"></button>
			<ss-button-dropdown :loc="loc" :loc-txt="gameTypeTxt" :list-items="gameTypes" :selected-item="pickedGameType" @onListItemClick="onGameTypeChange" @dropdownOpen="onGameTypeBtnOpen" @dropdownClosed="onGameTypeBtnClosed" sort="order"></ss-button-dropdown>
		</div>
		<!-- Popup: Pick Region -->
		<large-popup id="pickRegionPopup" ref="pickRegionPopup" @popup-closed="onPickRegionPopupClosed">
			<template slot="header">{{ loc.server }}</template>
			<template slot="content">
				<region-list-popup id="region_list_popup" ref="regionListPopup" v-if="(regionList.length > 0)" :loc="loc" :regions="regionList" :region-id="currentRegionId" @region-picked="onRegionPicked"></region-list-popup>
			</template>
		</large-popup>

		<!-- Popup: Join Private Game -->
		<large-popup id="joinPrivateGamePopup" ref="joinPrivateGamePopup" :class="joinOnlyCls" :popup-model="home.joinPrivateGamePopup" @popup-confirm="onJoinConfirmed" :hide-cancel="true" @popup-closed="onCloseCreateGame">
			<template slot="content">
				<div class="">
					<div v-show="!joinUrlRequest" class="play-panel-panels roundme_md">
						<create-private-game-popup id="createPrivateGame" ref="createPrivateGame" :loc="loc" :region-loc-key="regionLocKey" :is-game-ready="isGameReady" :picked-game-type="pickedGameType" :game-type-txt="gameTypeTxt" :game-types="gameTypes" @onGameTypeChange="onGameTypeChange" @onRegionPicked="onRegionPicked" map-img-base-path="maps/" :mapList="maps" :regions="regionList" :currentRegionId="currentRegionId"></create-private-game-popup>
						<div class="error_text shadow_red" v-show="home.joinPrivateGamePopup.showInvalidCodeMsg">{{ loc.p_game_code_blank }}</div>
					</div>
					<div class="play-panel-panels play-panel-panels-join roundme_md">
						<div class="private-game-wrapper fullwidth">
							<div class="inner-wrapper">
								<header>
									<h1 class="nospace">{{ loc.p_game_code_title }}</h1>
								</header>
								<div class="display-grid grid-column-2-1 gap-sm">
									<input type="text" class="ss_field fullwidth" v-model="home.joinPrivateGamePopup.code" v-bind:placeholder="loc.p_game_code_enter" @focus="onJoinGameFocus" v-on:keyup.enter="onJoinConfirmed">
									<button class="ss_button common-box-shadow ss_button_join" @click="onJoinConfirmed">{{ loc.p_game_code_title }}!</button>
								</div>
							</div>
						</div>
					</div>
				</div>
			</template>

			<template slot="cancel">{{ loc.cancel }}</template>
			<template slot="confirm">{{ loc.confirm }}</template>
		</large-popup>

		<small-popup id="showGameModePopup" ref="showGameModePopup" @popup-confirm="onGameModePopupConfirm">
			<template slot="header">Game Mode</template>
			<template slot="content">
			<div class="select-box-wrap">
				<label for="create-select-type" class="ss_button btn_yolk bevel_yolk"><i class="fas fa-chevron-down"></i></label>
				<select id="create-select-type" name="gameType" v-model="pickedGameType" class="ss_select select" @change="onGameTypeChange($event)">
					<option v-for="g in gameTypes" v-bind:value="g.value" :class="'game-select-' + g.locKey" v-html="loc[g.locKey]"></option>
				</select>
			</div>
			</template>
			<template slot="cancel">{{ loc.cancel }}</template>
			<template slot="confirm">{{ loc.confirm }}</template>
		</small-popup>
	</div>
</script>

<script id="region-list-template" type="text/x-template">
    <div>
        <h1 class="roundme_sm">{{ loc.p_servers_title }}</h1>
		{{ regions }} - {{ regionId }}
        <div v-for="r in regions" :key="r.id">
            <div id="region_list_item">
                <input type="radio" :id="('rb_' + r.id)" name="pickRegion" v-bind:value="r.id" v-model="regionId" @click="BAWK.play('ui_onchange')">
                <label :for="('rb_' + r.id)" class="regionName">{{ getLockText }} </label>
                <label :for="('rb_' + r.id)" class="regionPingWrap roundme_sm">
                    <span class="pingBar" :class="barColorClass(r)" :style="barStyle(r)"></span>
                </label>
                <label :for="('rb_' + r.id)" class="regionPingNumber ss_marginleft_lg"> {{ r.ping }}ms</label>
            </div>
        </div>
        <div id="btn_horizontal" class="f_center">
			<button @click="onConfirmClick()" class="ss_button btn_green bevel_green btn_sm">{{ loc.ok }}</button>
		</div>
    </div>
</script>

<script>
var comp_region_list_popup = {
    template: '#region-list-template',
    props: ['loc', 'regions', 'regionId'],

    data: function () {
        return {
            colorClasses: ['greenPing', 'yellowPing','orangePing', 'redPing'],
        }
    },

    methods: {
		playSound (sound) {
			BAWK.play(sound);
        },
        
        barColorClass: function (region) {
            var colorIdx = Math.min(3, Math.floor(region.ping / 150));
            return this.colorClasses[colorIdx];
        },

        barStyle: function (region) {
            return {
                width: (10 - Math.min(9, region.ping / 50)) + 'em'
            }
        },

        onConfirmClick: function () {
            this.$emit('region-picked', this.regionId);
            this.$parent.close();
            BAWK.play('ui_playconfirm');
        }
    },
	computed: {
		getLockText() {
			return extern.getLocText(this.locKey);
		}
	}
};
</script><template id="weaponselect_panel_template" type="text/x-template">
	<div class="center_h ss_marginbottom_sm">
		<div v-show="showDesc" class="grid-span-column-all text-center align-items-center ss_marginbottom_sm">
			<h3 class="nospace text_blue8">{{ weapon.title }}</h3>
			<p class="nospace text_blue3"><i>{{ weapon.desc }}</i></p>
		</div>
		<div :class="gridCls">
			<div class="nospace" @click="onWeaponSelect(charClass.Soldier)">
				<icon name="ico-weapon-soldier" class="weapon_img roundme_md" :cls="addSelectedCssClass(charClass.Soldier)"></icon>
			</div>
			<div class="nospace" @click="onWeaponSelect(charClass.Scrambler)">
				<icon name="ico-weapon-scrambler" class="weapon_img roundme_md" :cls="addSelectedCssClass(charClass.Scrambler)"></icon>
			</div>
			<div class="nospace" @click="onWeaponSelect(charClass.Ranger)">
				<icon name="ico-weapon-ranger" class="weapon_img roundme_md" :cls="addSelectedCssClass(charClass.Ranger)"></icon>
			</div>
			<div class="nospace" @click="onWeaponSelect(charClass.Eggsploder)">
				<icon name="ico-weapon-rpegg" class="weapon_img roundme_md" :cls="addSelectedCssClass(charClass.Eggsploder)"></icon>
			</div>
			<div class="nospace" @click="onWeaponSelect(charClass.Whipper)">
				<icon name="ico-weapon-whipper" class="weapon_img roundme_md" :cls="addSelectedCssClass(charClass.Whipper)"></icon>
			</div>
			<div class="nospace" @click="onWeaponSelect(charClass.Crackshot)">
				<icon name="ico-weapon-crackshot" class="weapon_img roundme_md" :cls="addSelectedCssClass(charClass.Crackshot)"></icon>
			</div>
			<div class="nospace" @click="onWeaponSelect(charClass.TriHard)">
				<icon name="ico-weapon-trihard" class="weapon_img roundme_md" :cls="addSelectedCssClass(charClass.TriHard)"></icon>
			</div>
		</div>
		<div v-if="currentScreen == screens.game && !disabler" class="grid-span-column-all text-center align-items-center ss_marginbottom_sm">
			<h3 class="nospace text_blue8">{{ weapon.title }}{{ selectedWeaponDisabled }}</h3>
			<p class="nospace text_blue3"><i>{{ weapon.desc }}</i></p>
		</div>
	</div>
</template>

<script>
var comp_weapon_select_panel = {
	template: '#weaponselect_panel_template',
	props: ['currentClass', 'loc', 'accountSettled', 'playClicked', 'currentScreen', 'screens', 'hideDesc', 'disabler'],

	data: function () {
		return {
			charClass: CharClass
		}
	},

	methods: {
		onWeaponSelect: function (classIdx) {
			if (!extern.inGame && (!this.accountSettled || this.playClicked || (this.currentClass === classIdx))) {
				return;
			}
			else {
				if (this.$parent.$attrs.id !== 'game_screen' && !this.disabler) {
					extern.changeClass(classIdx);
					this.$emit('changed-class', classIdx);
				}
				else if (this.disabler) {
					if (!extern.isGameOwner) return;
					vueApp.$nextTick(() => this.$forceUpdate());
					this.$emit('weapon-toggled', classIdx);
				}
				else {
					if (!extern.GameOptions.value.weaponDisabled[classIdx]) {
						extern.changeClass(classIdx);
						this.$emit('changed-class', classIdx);
					}
				}
				BAWK.play('ui_click');
			}
		},

		addSelectedCssClass: function (classIdx) {
			if (this.disabler) {
				let classes = '';

				if (vueData.gameOptionsPopup.options.weaponDisabled && vueData.gameOptionsPopup.options.weaponDisabled[classIdx]) {
					classes += 'weapon_disabled ';
				}

				if (!extern.isGameOwner) {
					classes += 'interactive-disabled ';
				}

				return classes;
			}
			else {
				if (this.$parent.$attrs.id === 'game_screen' &&
					extern.GameOptions.value &&
					extern.GameOptions.value.weaponDisabled[classIdx]
				) {
					return 'weapon_disabled noclick';
				}
				else if (this.currentClass === classIdx) {
					return 'weapon_selected';
				}
			}
			return '';
		}
	},
	computed: {
		weapon() {
			let className = getKeyByValue(this.charClass, this.currentClass).toLowerCase();
			return {
				title: this.loc[`weapon_${className}_title`],
				desc: this.loc[`weapon_${className}_content`],
			}
		},
		selectedWeaponDisabled () {
			let weap = this.disabler ?
				vueData.gameOptionsPopup.options.weaponDisabled :
				extern.GameOptions.value.weaponDisabled;

			return weap[this.currentClass] ? ` (${this.loc['p_weapon_disabled']})`: '';
		},

		isDisabled () {
			return this.disabled ? 'interactive-disabled' : '';
		},

		showDesc() {
			return !this.hideDesc && this.currentScreen !== this.screens.game;
		},

		gridCls() {
			if (this.currentScreen === this.screens.game) {
				return 'weapon-grid f_row f_wrap-wrap justify-content-center gap-sm';
			}
			return 'display-grid grid-auto-flow-column justify-content-around gap-sm';
		},

		containerCls() {
			return this.currentScreen === this.screens.game ? 'center_h' : '';
		}
	}
};
</script>

<script>
var comp_play_panel = {
	template: '#play-panel-template',
	components: {
		'create-private-game-popup': comp_create_private_game_popup,
		'region-list-popup': comp_region_list_popup,
		'weapon-select-panel': comp_weapon_select_panel,
	},

	props: ['loc', 'playerName', 'gameTypes', 'currentGameType', 'regionList', 'currentRegionId', 'home', 'isGameReady', 'maps', 'currentClass', 'showScreen', 'screens', 'playClicked', 'languageCode'],

	data: function() {
		return {
			pickedGameType: this.currentGameType,
			isButtonDisabled: true,
			playClickedBeforeReady: false,
			playClickFunction: Function,
			kotcPrompt: '',
			typeSelect: '',
			isPromptOpen: false,
			joinUrlRequest: false,
		}
	},
			
	methods: {
		onPickRegionButtonClick: function () {
			this.$refs.pickRegionPopup.toggle();
			BAWK.play('ui_popupopen');
		},
		
		onRegionPicked: function (regionId) {
			if (vueData.currentRegionId === regionId) { return; }
			
			vueData.currentRegionId = regionId;
			extern.selectRegion(vueData.currentRegionId);
			BAWK.play('ui_onchange');
		},

		onPickRegionPopupClosed: function () {
			if (this.$refs.createPrivateGame.showingRegionList) {
				this.$refs.createPrivateGame.showingRegionList = false;
				this.$refs.createPrivateGamePopup.toggle();
				this.$refs.createPrivateGame.onKeyDownMapSelect();
			}
		},

		onNameChange: function (event) {
			console.log('name changed to: ' + event.target.value);
			this.$emit('playerNameChanged', event.target.value);
		},

		onPlayerNameKeyUp: function (event) {
			event.target.value = extern.filterUnicode(event.target.value);
			event.target.value = extern.fixStringWidth(event.target.value);
			event.target.value = event.target.value.substring(0, 128);

			// Send username to server to start the game!
			if (event.code == "Enter" || event.keyCode == 13) {
				if (vueData.playerName.length > 0) {
					vueApp.externPlayObject(vueData.playTypes.joinPublic, this.pickedGameType, this.playerName, -1, '');
				}
			}
		},
		onGameTypeBtnOpen() {
			if (this.isWinSizeSmall()) {
				document.querySelector('.house-small').style.display = 'none';
				vueApp.hideTitleScreenAd();
			}
		},
		onGameTypeBtnClosed() {
			if (this.isWinSizeSmall()) {
				document.querySelector('.house-small').style.display = 'block';
				vueApp.showTitleScreenAd();
			}
		},
		isWinSizeSmall() {
			var win = window,
				doc = document,
				docElem = doc.documentElement,
				body = doc.getElementsByTagName('body')[0],
				x = win.innerWidth || docElem.clientWidth || body.clientWidth,
				y = win.innerHeight|| docElem.clientHeight|| body.clientHeight;
			// if (x <= 1366 && y <= 768) {
			if (x <= 1366) {
				return true;
			}
			return false;
		},

		onGameTypeChange: function (event) {
			let type;
			if (event.target !== undefined) {
				type = event.target.value;
			} else {
				type = event;
			}

			this.pickedGameType = type;
			this.$emit('game-type-changed', this.pickedGameType);
			extern.selectGameType(this.pickedGameType);
			BAWK.play('ui_onchange');
		},
		onPlayTypeWhenSignInComplete() {
			return this.playClickFunction();
		},
		onPlaySentBeforeSignIn(callback) {
			this.gameClickedBeforeReady = true;
			vueApp.showSpinner('signin_auth_title', 'signin_auth_msg');
			this.playClickFunction = callback;
		},
		hasValidPlayerNameCheck() {
			console.log('invalid player name');
			vueApp.showGenericPopup('play_pu_name_title', 'play_pu_name_content', 'ok');
			vueApp.hideSpinner();
			return;
		},
		onPlayButtonClick: function () {
			if (!hasValue(this.playerName)) {
				this.hasValidPlayerNameCheck();
				return;
			}
			if (!this.isGameReady) {
				this.onPlaySentBeforeSignIn(this.onPlayButtonClick);
				return;
			}

			this.onCloseCreateGame();
			vueApp.game.respawnTime = 0;
			vueApp.externPlayObject(vueData.playTypes.joinPublic, this.pickedGameType, this.playerName, -1, '');
			BAWK.play('ui_playconfirm');
		},

		onCloseCreateGame() {
			this.$refs.createPrivateGame.removeKeydown();
		},

		onJoinPrivateGameClick: function () {
			this.showJoinPrivateGamePopup(vueData.home.joinPrivateGamePopup.code);
			BAWK.play('ui_popupopen');
		},

		showJoinPrivateGamePopup: function (showCode, urlRequest) {
			// The popup must be active before it will update; set code after showing

			this.joinUrlRequest = hasValue(urlRequest);
			this.$refs.joinPrivateGamePopup.show();
			this.$refs.createPrivateGame.onKeyDownMapSelect();

			vueData.home.joinPrivateGamePopup.code = showCode;
		},

		onJoinConfirmed: function () {
			if (!hasValue(this.playerName)) {
				this.hasValidPlayerNameCheck();
				return;
			}
			if (!this.isGameReady) {
				this.onPlaySentBeforeSignIn(this.onJoinConfirmed)
				return;
			}

			let match = null;

			if (vueData.home.joinPrivateGamePopup.code.match(/\#\w+/)) {
				match = vueData.home.joinPrivateGamePopup.code.match(/\#\w+/)[0];
			} else if (vueData.home.joinPrivateGamePopup.code.includes('crazyShare')) {
				match = vueData.home.joinPrivateGamePopup.code.match(/=\w*$/)[0].substring(1);
			}
			else { // In case someone copy/pastes the thing without including the #
				match = vueData.home.joinPrivateGamePopup.code;
			}

			if (!match) {
				return;
			}

            match = match.trim();
            if (match.startsWith('#')) match = match.substring(1)

			vueData.home.joinPrivateGamePopup.code = match;

			this.$refs.joinPrivateGamePopup.hide();

			// checking if the invite code is being used since, we are only trying to determine
			extern.onJoinGameClick = true;
			vueApp.externPlayObject(vueData.playTypes.joinPrivate, '', this.playerName, '', vueData.home.joinPrivateGamePopup.code);
		},
		kotcAttachSetup() {
			const typePostion = this.typeSelect.getBoundingClientRect();
			const kotcPrompt = this.kotcPrompt.getBoundingClientRect();

			this.kotcPrompt.style.top = typePostion.top + 'px';
			this.kotcPrompt.style.left = typePostion.right + 16 + 'px';
		},

		anchorKotcPrompt() {
			this.$nextTick(() => this.kotcAttachSetup());
		},
		onGameTypeClick() {
			if (this.isPromptOpen) {
				this.isPromptOpen = false;
			} else {
				this.isPromptOpen = true;
			}
			// this.$refs.showGameModePopup.show();
		},
		onGameModePopupConfirm() {
			this.$refs.showGameModePopup.hide();
		},

		onJoinGameFocus() {
			this.$refs.createPrivateGame.removeKeydown();
		},
		onChangedClass() {
			vueApp.$refs.equipScreen.onChangedClass();
		}
	},

	computed: {
		regionLocKey: function () {
			if (!hasValue(this.regionList) || this.regionList.length === 0) {
				return '';
			}

			var region = this.regionList.find(r => {
				return r.id == vueData.currentRegionId;
			});

			return hasValue(region) ? 'server_' + region.id : '';
		},
		regionName: function () {
			if (!hasValue(this.regionList) || this.regionList.length === 0) {
				return 'N/A';
			}

			var region = this.regionList.find(r => {
				return r.id == vueData.currentRegionId;
			});

			if (!region) return 'N/A';

			return this.loc[region.locKey] || region.id;
		},

		selectedGameType() {
			return this.loc[this.gameTypes.filter(el => el.value === this.pickedGameType)[0]['locKey']]; 
		},
		gameTypeTxt() {
			return {
				title: this.loc.stat_game_mode,
				subTitle: this.loc[this.gameTypes.filter(el => el.value === this.pickedGameType)[0]['locKey']]
			}
		},
		serverText () {
			return {
				title: this.loc.p_servers_title,
				subTitle: this.currentRegionId ? this.loc[`server_${this.currentRegionId}`] : '',
			}
		},
		playBtn() {

			if (this.languageCode == 'de' || this.languageCode == 'es' || this.languageCode == 'pt' || this.languageCode == 'nl'){
				return `<i class="fa fa-play fa-sm"></i> <span>${this.loc.home_play}</span>`
			}
			return `<i class="fa fa-play fa-sm"></i> ${this.loc.home_play}`;
		},
		joinOnlyCls() {
			return this.joinUrlRequest ? 'join-request-only' : '';
		}

	},
	watch: {
		currentGameType: function (val) {
			this.pickedGameType = val;
		},
		isGameReady(val) {
			this.isButtonDisabled = val ? false : true;
			if (this.gameClickedBeforeReady && val) {
				this.onPlayTypeWhenSignInComplete()
			}
		}
	}
};
</script><script id="newsfeed-panel-template" type="text/x-template">
	<section class="news-panel">
		<article v-if="items" v-for="item in activeItems" :key="item.id" @click="onItemThatIsClicked(item)" class="media-item news_item clickme">
			<img :src="imageSrc(item)" class="news_img roundme_sm">
			<p>{{ item.content }}</p>
		</article>
	</section>
</script>

<script>
var comp_newsfeed_panel = {
	template: '#newsfeed-panel-template',
	props: ['items'],

	data: function () {
		return vueData;
	},

	// mounted: function () {
	// 	// this.fetchWebData();
	// 	this.checklocalForNewsData();
	// },

	methods: {
		imageSrc(item) {
			return dynamicContentPrefix + 'data/img/newsItems/' + item.id + item.imageExt;
		},
		onItemThatIsClicked(item) {
			console.log(item);
			extern.clickedWebFeedItem(item);
			BAWK.play('ui_click');
		},
	},
	computed: {
		activeItems() {
			return this.items.filter(item => item.active);
		}
	}
};
</script><script id="chicken-panel-template" type="text/x-template">
	<div id="showBuyPassDialogButton" class="new">
		<div class="chicken-panel--upgraded" v-show="doUpgraded && !isSubscriber">
			<div class="tool-tip tool-tip--right">
				<span v-if="nugCounter" id="nugget-countdown">{{nugCounter}} Minutes remaining.</span>
				<img class="upgraded-nugget" src="img/chicken-nugget/goldenNugget_static.webp">
				<!-- <div id="nugget-timer" class="nugget-timer--wrapper">
					<div class="timer-background"></div>
					<div class="timer spinner"></div>
					<div class="timer filler"></div>
					<div class="mask"></div>
				</div> -->
			</div>
		</div>
		
		<div class="chicken-panel--no-upgraded" v-show="!doUpgraded">
			<img src="img/chicken-nugget/starburst.webp" @click="onChickenClick" class="clickme starburst">
			<img src="img/chicken-nugget/goldenNuggetGIFWIP.gif" @click="onChickenClick" class="clickme nugget-chick">
		
			<div id="buyPassChickenSpeech">
				<img src="img/speechtail.webp" class="buyPassChickenSpeechTail">
				<span v-html="loc.chicken_cta"></span>
			</div>
		</div>
	</div>
</script>

<script>
var comp_chicken_panel = {
	template: '#chicken-panel-template',
	props: ['local', 'doUpgraded'],
	data: function () {
		return vueData;
    },
	methods: {
		onChickenClick: function () {
			BAWK.play('ui_chicken');
			vueApp.showGoldChickenPopup();
			ga('send', 'event', this.googleAnalytics.cat.purchases, 'Golden Chicken Click');
		},
	},
};
</script><script id="footer-links-panel-template" type="text/x-template">
	<footer class="main-footer">
		<!-- <section class="social-icons">
			<social-panel id="social_panel" :loc="loc" :is-poki="isPoki" :use-social="selectedSocial" :social-media="socialMedia"></social-panel>
		</section> -->
		<section class="centered">
			<nav class="footer-nav text-center">
				<button @click="onChangelogClicked" class="clickme ss_button_as_text">{{ version }}</button> | 
				<!-- <a href="https://shell-shockers.myshopify.com/collections/all" target="_blank" @click="BAWK.play('ui_click')">{{ loc.footer_merchandise }}</a> |  -->
				<button class="ss_button_as_text" target="_blank" @click="openInNewTab('https://www.bluewizard.com/privacypolicy')">{{ loc.footer_privacypolicy }}</button> | 
				<button class="ss_button_as_text" target="_blank" @click="openInNewTab('https://bluewizard.com/terms/')">{{ loc.footer_termsofservice }}</button> | 
				<button class="ss_button_as_text" @click="onHelpClick">{{ loc['account_title_faq'] }}</button> | 
				<button class="ss_button_as_text" target="_blank" @click="openInNewTab('https://www.bluewizard.com')">&copy; 2024 <img class="main-footer--logo-blue-wiz-mini" src="img/blue-wizard-logo-tiny-min.webp" :alt="loc.footer_bluewizard + ' logo'"><span class="hideme">{{ loc.footer_bluewizard }}</span></button>
			</nav>
		</section>
	</footer>
</script>

<script>
var comp_footer_links_panel = {
	template: '#footer-links-panel-template',
	props: ['loc', 'version', 'isPoki', 'socialMedia', 'selectedSocial'],

	methods: {
		onChangelogClicked: function () {
			vueApp.showChangelogPopup();
			BAWK.play('ui_popupopen');
		},
		playSound() {
			BAWK.play('ui_click');
		},
		onHelpClick() {
			vueApp.showHelpPopup();
			// this.gaSend('openHelp');
			BAWK.play('ui_popupopen');
		},
		openInNewTab(url) {
			window.open(url, '_blank').focus();
			this.playSound();
		}
	}
};
</script>
<template id="comp-vip-cta">
	<div class="house-ad-wrapper">
		<div class="vip-club-cta" v-show="isVisible">
			<button v-if="!isSubscriber && hasMobileReward && showVip" class="vip-club-cta-pos ss_button btn_sm btn_pink bevel_pink" @click="onClicked">
				{{ loc.ui_game_playeractions_join_vip }}
			</button>
			<h4 v-if="isSubscriber && showVip" class="sub-name">
				{{loc[subName]}}
			</h4>
			<img class="house-ad-img" :class="imgCls" :src="imgSrc" :alt="altText" @click="adOnClick">
		</div>
		<div v-if="!isCrazyGames" class="ss_margintop box_relative">
			<a href="https://freegames.io/game/shell-shockers?utm_source=shellshockershomepage&utm_medium=referral" target="_blank" title="Play Free Games on... well, Free Games dot io">
				<img v-lazyload :data-src="freeGamesImg" alt="FreeGames.io logo" class="display-block center_h free-games-logo lazy-load">
			</a>
		</div>
	</div>
</template>

<script>
    const CompHouseAd = {
        template: '#comp-vip-cta',
        props: ['loc', 'upgradeName', 'isUpgraded', 'isSubscriber', 'hasMobileReward', 'isPoki', 'chwCount', 'chwReady', 'chwLimitReached', 'ad', 'crazyGamesActive', 'inGame'],
		data: function () {
            return {
				isVisible: true,
				isCrazyGames : false,
				freeGamesImg: 'img/free-games-io.webp',
			}
		},
		created() {
			crazyGamesHouseAdCheck = this;
		},
        methods: {
			adOnClick() {
				extern.clickedHouseLink(this.ad);
			},
        },
		computed: {
			imgSrc() {
				if (this.ad === null) {
					return;
				}
				return dynamicContentPrefix + 'data/img/art/' + this.ad.id + this.ad.imageExt;
			},

			altText() {
				if (this.ad === null) {
					return;
				}
				return this.ad.id.label;
			},

			getImgSrcAlt() {
				if (this.useEventData) {
					return this.eventData.event[this.useEventData].alt;
				} else {
					if (!this.isPoki) {
							if (this.hasMobileReward) {
								return this.eventData.event.vipImgSrc.alt;
							} else {
								return this.eventData.event.mobile.alt;
							}
						}
				}
			},
			showVip() {
				return false;
				if (!this.hasPlayedKotc || !this.hasMobileReward || this.isBlackFryday) {
					return false;
				} else {
					return true;
				}
			},
			imgCls() {
				if (this.ad === null) {
					return;
				}
				return `${this.ad.label.replace(/\s+/g, '-').toLowerCase()}-img`;
			},
		},
        watch: {
            upgradeName(val) {
                if (!hasValue(val)) {
                    return;
                }
                this.subName = `s-${val.replace(' ', '-').toLowerCase().replace(' ', '-')}-title`;
            },
			inGame(val) {
				if (val && this.ad && this.ad.linksTo === 'linksToCreateGame') {
					this.isVisible = false;
				} else {
					this.isVisible = true;
				}
			},
        }
    };
</script><script id="media-tabs-template" type="text/x-template">
	<div>		
		<div class="media-tabs-wrapper box_relative border-blue5 roundme_sm bg_blue6 common-box-shadow ss_margintop_sm">
			<div class="media-tab-container display-grid align-items-center gap-sm bg_blue3">
				<h4 class="common-box-shadow text-shadow-black-40 text_white dynamic-text">
					<div class="dynamic-text" style="width: 8em;"><div class="dynamic-text">{{ tabName }}</div></div>
					<span v-if="currentTab === 'challenges-tab'">
						<span v-if="hasChlgs" class="text_yellow_bright font-nunito font-800 justify-self-end nospace"><span v-show="challengeDailyData.days">D: {{ challengeDailyData.days }}</span> <span>{{ challengeDailyData.hours }}</span>:<span>{{ challengeDailyData.minutes }}</span>:<span>{{ challengeDailyData.seconds }}</span></span>
					</span>
				</h4>
				<div class="display-grid grid-auto-flow-column gap-sm">
					<button v-for="(tab, idx) in mediaTabs" :key="idx" :id="tab.id" @click="onTabClicked(tab.id)" class="media-tab ss_smtab roundme_sm nospace" :class="(currentTab === tab.id ? 'selected' : '')"><i :class="tab.icon"></i></button>
				</div>
			</div>
			<div class="media-tabs-content f_col" :class="(currentTab === 'news-tab' ? 'tab-news-active' : '')">
				<div class="tab-content" :class="tabContentStyle">
					<div ref="newsContainer" class="news-container f_row" :class="newsContainerStyle">
						<player-challenge-list v-show="currentTab === 'challenges-tab'" :loc="loc" :challenges="challenges" :challenge-data="challengeDailyData" :in-game="false" @chlgReroll="challengeReroll"></player-challenge-list>
						<!-- <newsfeed-panel v-show="currentTab === 'news-tab'" id="news_scroll" class="media-tab-scroll" ref="newsScroll" :items="newsItems	"></newsfeed-panel> -->
						<media-panel v-show="currentTab === 'news-tab'" id="news_scroll" class="media-tab-scroll" :items="news" type="news" :loc="loc"></media-panel>
						<media-panel v-show="currentTab === 'twitch-tab'" id="news_scroll" class="media-tab-scroll" :items="twitch" type="twitch" :loc="loc"></media-panel>
						<media-panel v-show="currentTab === 'video-tab'" id="news_scroll" class="media-tab-scroll" :items="youTube" type="youtube" :loc="loc"></media-panel>
						<!-- <streamer-panel v-show="currentTab === 'twitch-tab'" id="twitch_panel" :loc="loc" :streams="twitchStreams" :title="loc.twitch_title" :viewers="loc.twitch_viewers" icon="ico_twitch"></streamer-panel> -->
					</div>
				</div>
				<!-- #news-tab -->
			</div>
		<!-- .media-tabs-content -->
		</div>
	  <!-- .media-tabs-container -->
	</div>
</script>

<template id="player_challenge_list">
    <div class="player-challenges-aside box_relative bg_blue6" :class="wrapStyle">
        <div v-if="inGame" class="media-tab-container media-tab-challenges display-grid align-items-center gap-sm bg_blue3">
			<div class="dynamic-text" style="width: 12.5em;">
				<h4 class="common-box-shadow text-shadow-black-40 text_white dynamic-text">{{ loc.challenges }}</h4>
			</div>
            <p class="text_yellow_bright font-nunito font-800 justify-self-end text-shadow-black-40 nospace">
                <i v-show="hasChlgs" class="far fa-clock"></i>
                <span v-show="!hasChlgs" class="font-size-md">No challenges!</span>
                <span v-if="hasChlgs">{{ challengeData.hours }}:{{ challengeData.minutes }}:{{ challengeData.seconds }}</span>
            </p>
        </div>
        <div class="news-container f_row">
            <section class="player-challenges-container overflow-hidden">
                <player-challenge v-for="challenge in challenges" :key="challenge.challengeId" :loc="loc" :data="challenge" :timers="timers" @chlg-reroll="challengeReroll"></player-challenge>
            </section>
        </div>
    </div>
</template>

<script id="player_challenge" type="text/x-template">
	<div class="player-challenge-single box_relative display-flex align-items-center f_row">
		<div v-if="completed" class="checkmark-wrap">
			<icon name="ico-checkmark"></icon>
		</div>
		<div class="player-chal lenge-single-wrap ss_paddingright ss_paddingleft display-grid grid-column-1-2 align-items-center gap-sm fullwidth">
			<div ref="content" class="player-challenge-single-content">
				<header>
					<div ref="title" class="nospace dynamic-title" style="width: 100%; height: 1em">
						<h4 class="player-challenge-single-name font-size-lg nospace text_blue5 line-height-1 dynamic-text">{{ title }}</h4>
					</div>
					<div ref="desc" class="nospace dynamic-title" style="width: 100%; height: 1em">
						<p class="nospace text_yellow_bright font-size-lg font-nunito dynamic-text">{{ desc }}</p>
					</div>
				</header>
				<div v-show="!data.claimed" class="player-challenge-single-progress display-grid grid-column-2-1 align-items-center">
					<div class="player-challenge-single-progress-wrap roundme_md bg_blue5">
						<div class="player-challenge-single-progress-bar bg_yellow roundme_md" :style="{ width: progress + '%' }"></div>
						<!-- <div class="player-challenge-single-progress-bar bg_yellow roundme_md" style="width: 10%"></div> -->
					</div>
					<div class="font-size-md ss_marginleft_sm text_blue5 font-800">
						{{ trueProgress }}/{{ getGoal }}
					</div>
				</div>
				<div class="display-grid grid-column-2-eq align-items-center">
					<div class="player-challenge-single-reward text-shadow-black-40 display-grid align-items-center grid-column-auto-1 gap-sm">
						<img src="img/svg/ico_goldenEgg.svg"> {{ reward }}
					</div>
					<div class="player-challenge-single-action justify-self-end margin-0 box_relative" :class="actionState">
						<div v-show="showActionBtn" class="player-challenge-tool-tip box_relative">
							<div class="tool-tip">
								<button class="ss_button pause-screen-ui margin-0 player-challenge-single-action-btn" :disabled="onRerollClicked" :class="actionBtnStyle" @click="onActionBtnClick"><i v-show="!data.reset && !completed" class="fas fa-sync-alt"></i> <span>{{ actionBtnContent }}</span></button>
								<span v-if="!completed" class="tool-tip-text">{{ loc.challenges_reroll }}</span>
							</div>
						</div>
						<div v-show="actionContentShow">
							<p class="nospace text_blue3 player-challenge-claimed">{{ actionBtnContent }}</p>
						</div>
					</div>
				</div>
			</div>
			<figure class="player-challenge-single-icon nospace f_row align-items-center">
				<img :src="imgSrc" class="display-block center_h" alt="">
			</figure>
			<!-- <div>Completion indicatior</div> -->
		</div>
	</div>
</script>

<script>
const CompPlayerChallengeSingle = {
    template: '#player_challenge',
	props: ['loc', 'data', 'timers'],
    data () {
        return {
			now: 0,
			diff: 0,
			end: 0,
			minutes: 0,
			seconds: 0,
			hours: 0,
			days: 0,
			gap: 0,
			timerDisplay: '',
			reward: 0,
			reset: 0,
			goal: 0,
			period: 0,
			locRef: '',
			type: '',
			subType: '',
			challengeData: '',
			onClaimClicked: false,
			onRerollClicked: false,
			conditional: '',
			value: null,
			valueTwo: null,
        }
    },

	mounted() {
		this.now = Math.trunc((Date.now()/1000));
		this.end = this.now + this.data.period;
		const dbData = extern.Challenges.filter(chlg => chlg.id === this.data.challengeId)[0];

		this.reward = dbData.reward;
		this.goal = dbData.goal;
		this.period = dbData.period;
		this.locRef = dbData.loc_ref;
		this.value = dbData.value;
		this.valueTwo = dbData.valueTwo;

		if (dbData.conditional !== null) {
			this.conditional = ChallengeConditions[dbData.conditional];
		}

		this.type = ChallengeType[dbData.type];
		this.subType = ChallengeSubType[dbData.subType];
		setInterval(this.timer, 1000);

	},

    methods: {
		onActionBtnClick(e) {
			if (!this.data.reset && !this.completed) {
				if (!this.onRerollClicked) {
					this.onRerollClicked = true;
					BAWK.play('ui_reset');
					this.$emit('chlg-reroll', this.data.challengeId);
					// this.$emit('chlgReroll', this.data.challengeId);
				}
			} else {
				if (!this.onClaimClicked) {				
					this.onClaimClicked = true;
					BAWK.play('pickup');
					extern.playerChallenges.claim(this.data.challengeId);
				}
			}
		},

		timer() {
			this.gap = Math.floor(this.end - (Math.trunc(Date.now()/1000)));

			if (this.gap < 0) {
				this.gap = 0;
				this.progress = 100;
			}

			let hoursLeft = 0;
			let minutesLeft = 0;

			this.days = Math.floor(this.gap/24/60/60);
			hoursLeft = Math.floor((this.gap) - (this.days*86400));
			this.hours = this.timeFormat(Math.floor(hoursLeft/3600));
			minutesLeft = Math.floor((hoursLeft) - (this.hours*3600));
			this.minutes = this.timeFormat(Math.floor(minutesLeft/60));
			this.seconds = this.timeFormat(this.gap % 60);

		},
		timeFormat(time) {
			return time < 10 ? '0' + time : time;
		},
		resizeTextToFit(container, maxFontSize) {
			const text = container.querySelector('.dynamic-text');
			const containerWidth = container.clientWidth;
			const containerHeight = container.clientHeight;

			let fontSize = maxFontSize; // Start with a base font size in em
			text.style.fontSize = fontSize + 'em';

			// Increase font size until it overflows
			while (text.scrollWidth <= containerWidth && text.scrollHeight <= containerHeight) {

				fontSize += 0.1;
				if (fontSize >= maxFontSize) {
					fontSize -= 0.1;
					break;
				}
					text.style.fontSize = fontSize + 'em';
			}

			// Step back to last valid font size
			fontSize -= 0.1;

			text.style.fontSize = fontSize + 'em';

			// Fine-tune decrease to avoid overflow
			while (text.scrollWidth > containerWidth || text.scrollHeight > containerHeight) {
				fontSize -= 0.01;
				text.style.fontSize = fontSize + 'em';
				if (fontSize < 0.5) break; // Prevent the font size from becoming too small
			}
		},
		dynamicChallengeText() {
			setTimeout(() => {
				this.resizeTextToFit(this.$refs.title, .9);
				this.resizeTextToFit(this.$refs.desc, .75);
			}, 100);
		}
    },

    computed: {
		title() {
			this.dynamicChallengeText();
			return this.loc[this.locRef + '_title'];
		},
		desc() {
			return this.loc[this.locRef + '_desc'];
		},

		imgSrc() {
			return extern.playerChallenges.iconSrc(this.locRef);
		},

		progress() {
			const p = Math.floor((this.data.progress/this.data.goal)*100);
			return p > 100 ? 100 : p;
		},
		completed() {
			return this.data.progress >= this.data.goal || this.data.completed;
			// return true;
		},
		showActionBtn() {
			if (this.data.claimed || (this.data.reset && this.completed && this.data.claimed) || (this.data.reset && !this.completed)) {
				return false;
			} else {
				return true;
			}
		},
		actionBtnStyle() {
			if (!this.completed && !this.data.claimed) {
				return 'btn_blue bevel_blue box_relative text-shadow-none text_blue1 btn_sm';
			} else if (this.completed && !this.data.claimed) {
				return 'btn_pink bevel_pink box_relative text-shadow-none text_white btn_sm';
			}
		},
		actionContentShow() {
			return this.data.reset && !this.completed || this.data.claimed && this.completed;
		},
		actionBtnContent() {
			if (this.completed && !this.data.claimed) {
				return this.loc.claim;
			} else if (this.completed && this.data.claimed) {
				return this.loc.claimed;
			} else if (!this.completed && !this.data.claimed && this.data.reset) {
				return '';
			}
		},
		trueProgress() {
			let p, gc_mem_caches;
			if (this.subType === 'timePlayed' && this.type !== 'kills') {
				p = Math.floor(this.data.progress / 60);
				g = Math.floor(this.data.goal / 60);
			} else {
				p = this.data.progress;
				g = this.data.goal;
			}
			return p >= g ? g : p;
		},
		actionState() {
			if (this.data.claimed) {
				return 'player-challenge-single-action-claimed';
			} else if (this.data.reset && this.completed) {
				return 'player-challenge-single-action-completed';
			}
		},
		timerData() {
			if (this.subType === 'timePlayed') {
				return this.timers.played;
			} else if (this.subType === 'timeAlive') {
				return this.timers.alive;
			}
		},
		getGoal () {
			if (this.subType === 'timePlayed' && this.type !== 'kills') {
				return  Math.floor(this.data.goal / 60) + 'm';
			} else {
				return this.data.goal;
			}
		}
	},
};
</script>
<script>
const CompPlayerChallengeList = {
    template: '#player_challenge_list',
	components: {
            'player-challenge': CompPlayerChallengeSingle,
        },
	props: ['loc', 'challenges', 'challengeData', 'timers', 'inGame'],
    data () {
        return {
			chlgsBeforeReroll: [],
			chlgRerollID: null,
        }
    },

	mounted() {
	},

    methods: {
		challengeReroll(challengeId) {
			this.chlgRerolled = challengeId;
			this.chlgsBeforeReroll = this.challenges;
			extern.playerChallenges.reroll(challengeId);
		},
		
    },

    computed: {
		hasChlgs() {
			return Array.isArray(this.challenges) && this.challenges.length > 0 ? true : false;
		},
		wrapStyle() {
			if (this.inGame) {
				return 'border-blue5 roundme_sm common-box-shadow';
			} else {
				return 'home-screen';
			}
		}
	},
	watched: {
        challenges(newChallenges) {
            if (this.chlgRerolled && this.chlgsBeforeReroll.length > 0 && this.chlgRerollID !== null) {
                const oldChallenges = this.chlgsBeforeReroll;

                // Find the new challenge that is not in the old challenges
                const newChallenge = newChallenges.find(newChlg => 
                    !oldChallenges.some(oldChlg => oldChlg.id === newChlg.id)
                );

                if (newChallenge) {
                    // Find the index of the missing challenge in the old data using chlgRerollID
                    const missingChallengeIndex = oldChallenges.findIndex(oldChlg => oldChlg.id === this.chlgRerollID);

                    if (missingChallengeIndex !== -1) {
                        // Create a new array maintaining the original order
                        const updatedChallenges = [...oldChallenges];
                        updatedChallenges.splice(missingChallengeIndex, 1, newChallenge);
                        this.challenges = updatedChallenges;
                    }
                }

				this.chlgsBeforeReroll = [];
				this.chlgRerollID = null;		
            } else {
				this.challenges = newChallenges;
			}
        }
	}
};
</script><script id="media-panel" type="text/x-template">
	<section class="media-panel news-panel">

		<component :is="type" v-for="(item, idx) in items" :item="item" :key="idx" :loc="loc"></component>

		<div class="no-stream roundme_sm" v-if="items.length < 1 && type === 'twitch'">
			<p v-html="loc.twitch_no_steam"></p>
		</div>

		<div class="f_row" v-if="showNav">
			<button class="ss_button btn_sm btn_yolk bevel_yolk btn_media-nav text_blue5" @click="backItem">
				<i class="fas fa-chevron-left"></i>
			</button>
			<button class="ss_button btn_sm btn_yolk bevel_yolk btn_media-nav text_blue5" @click="nextItem">
				<i class="fas fa-chevron-right"></i>
			</button>
			<span>({{currentSpot}} / {{ maxSpot }})</span>
		</div>
	</section>
</script>

<script id="news-content" type="text/x-template">
	<article @click="onItemThatIsClicked" class="media-item news_item clickme media-item-border">
	<img :data-src="imageSrc" ref="newsImage" class="news_img roundme_sm" />
		<p>{{ item.content }}</p>
	</article>
</script>

<script>
var NewsContent = {
	template: '#news-content',
	props: {
		item: {
			type: Object,
			default: () => {
				return {
					title: '',
					content: '',
					id: '',
					imageExt: '',
				}
			}
		},
	},
	mounted() {
		const observer = new IntersectionObserver((entries, observer) => {
			entries.forEach(entry => {
				if (entry.isIntersecting) {
					this.loadImage(); // Load image when in view
					observer.unobserve(entry.target); // Stop observing once loaded
				}
			});
		}, {
			rootMargin: '0px 0px 200px 0px', // Preload slightly before visible
		});

		observer.observe(this.$refs.newsImage); // Observe the image element
	},
	methods: {
		onItemThatIsClicked() {
			console.log(this.item);
			extern.clickedWebFeedItem(this.item);
			BAWK.play('ui_click');
		},
		loadImage() {
			const img = this.$refs.newsImage;
			img.src = img.dataset.src;
		},
	},
	computed: {
		imageSrc() {
			return dynamicContentPrefix + 'data/img/newsItems/' + this.item.id + this.item.imageExt;
		},
	}
};
</script><script id="streamer-panel-template" type="text/x-template">
	<div class="panel_streamer noscroll media-item-border">
		<div id="stream_scroll" v-if="item.name">
			<div class="media-item stream_item clickme">
				<a :href="item.link" target="_blank" class="f_row">
				<img :data-src="item.image" ref="streamerImage" class="stream_img roundme_sm ss_marginright" />
					<span>
						<p class="stream_name">{{ item.name }}</p>
						<p v-if="item.viewers" class="stream_viewers">{{ item.viewers }} Viewers</p>
					</span>
				</a>
			</div>
		</div>
		<div class="no-stream roundme_sm" v-if="!item.name">
			<p v-html="loc.twitch_no_steam"></p>
		</div>
	</div>
</script>

<script>
	var comp_streamer_panel = {
		template: '#streamer-panel-template',
		props: {
			item: {
				type: Object,
				default: () => {
					return {
						name: '',
						viewers: '',
						link: '',
						image: '',
					}
				}
			},
			loc: {
				type: Object,
				default: () => {
					return {
						twitch_no_steam: '',
					}
				}
			}
		},
		mounted() {
			const observer = new IntersectionObserver((entries, observer) => {
				entries.forEach(entry => {
					if (entry.isIntersecting) {
						this.loadImage(); // Load the image when in view
						observer.unobserve(entry.target); // Stop observing once loaded
					}
				});
			}, {
				rootMargin: '0px 0px 200px 0px', // Preload slightly before visible
			});

			observer.observe(this.$refs.streamerImage); // Observe the image element
		},
		methods: {
			playSound (sound) {
				BAWK.play(sound);
			},
			loadImage() {
				const img = this.$refs.streamerImage;
				img.src = img.dataset.src;
			},
		}
	};
</script><script id="youtube-content-template" type="text/x-template">
	<article @click="onVideoClick()" class="media-item ytube-item clickme media-item-border">
		<div class="image-wrap news_img roundme_sm">
			<img :data-src="imgSrc" alt="" class="news_img" ref="lazyImage" />
		</div>
		<div class="content-wrap f_col f_space_between">
			<p>{{ item.title }}</p>
			<p v-if="item.desc">{{ item.desc }}</p>
			<p class="text-right">{{ item.author }}</p>
		</div>
	</article>
</script>
<script>
var YoutubeContent = {
	template: '#youtube-content-template',
	props: {
		item: {
			type: Object,
			default: () => {
				return {
					title: '',
					desc: '',
					author: '',
					link: '',
					externalImg: '',
				}
			}
		},
	},

	data: function () {
		return {
		};
	},
	mounted() {
		const observer = new IntersectionObserver((entries, observer) => {
			entries.forEach(entry => {
				if (entry.isIntersecting) {
					this.loadImage(); // Call method to load the image
					observer.unobserve(entry.target); // Stop observing after the image is loaded
				}
			});
		}, {
			rootMargin: '0px 0px 200px 0px', // Preload the image before it comes fully into view
		});

		observer.observe(this.$refs.lazyImage);
	},
	methods: {
		onVideoClick() {
			ga('send', 'creator', 'videoClick', this.item.title);
			window.open(this.item.link, '_window');
		},
		loadImage() {
			const img = this.$refs.lazyImage;
			img.src = img.dataset.src;
		},
	},
	computed: {
		imgSrc() {
			if (this.item.externalImg.includes('hqdefault')) {
				return this.item.externalImg.replace('hqdefault', 'mqdefault');
			}
			return this.item.externalImg;
		},
	},
	watch: {
		item: function (newVal, oldVal) {
			console.log('newVal', newVal);
			console.log('oldVal', oldVal);
		}
	}
};
</script>

<script>
var CompMediaPanel = {
	template: '#media-panel',
	components: {
		'news': NewsContent,
		'twitch': comp_streamer_panel,
		'youtube': YoutubeContent,
	},
	props: {
		items: {
			type: Array,
			default: () => []
		},
		type: {
			type: String,
			default: ''
		},
		loc: {
			type: Object,
			default: {}
		},
	},

	data: function () {
		return {
			currentIdx: 0,
			maxIdx: 0,
			showNav: false,
		};
	},
	methods: {
		nextItem() {
			if (this.maxIdx === this.currentIdx) {
				this.currentIdx = 0;
			} else {
				this.currentIdx ++;
			}
		},
		backItem() {
			if (this.currentIdx === 0) {
				this.currentIdx = this.maxIdx;
			} else {
				this.currentIdx --;
			}
		}
	},
	computed: {
		showItem() {
			return this.items[this.currentIdx];
		},
		showNews() {
			return this.type === 'news';
		},
		showTwitch() {
			return this.type === 'twitch';
		},
		showYoutube() {
			return this.type === 'youtube';
		},
		currentSpot() {
			return this.currentIdx + 1;
		},
		maxSpot() {
			return this.maxIdx + 1;
		}
	},
	watch: {
		// items: function(val) {
		// 	if (val.length > 0) {
		// 		this.showNav = true;
		// 		this.maxIdx = this.items.length - 1;
		// 	}
		// }
	}
};
</script>
<script>
    const MEDIATABS = {
        template: '#media-tabs-template',
        components: {
            'player-challenge-list': CompPlayerChallengeList,
			'media-panel': CompMediaPanel
        },
        props: ['loc', 'newsfeedItems', 'twitchStreams', 'youtubeStreams', 'challenges', 'challengeDailyData', 'firebaseId'],

        mounted() {
			// this.autoRotateTabs();
			const tabs = document.querySelector('.news-container');

			tabs.addEventListener('mouseenter', (e) => {
				clearTimeout(this.rotateTimeout);
			});
			this.$nextTick(() => {
				this.fetchJson();
			});
			this.randomTabSelect();
			this.autoRotateTabs();
        },

        data: function () {
            return {
                mediaTabs: [
					{
						id: 'news-tab',
						name: 'News',
						icon: 'fas fa-bullhorn'
					},
					{
						id: 'twitch-tab',
						name: 'Twitch',
						icon: 'fab fa-twitch'
					},
					{
						id: 'video-tab',
						name: 'YouTube',
						icon: 'fab fa-youtube'
					}
				],
				news: [],
				twitch: [],
				youTube: [],
                delay: 7000,
                rotateTimeout: '',
                currentTab: 'news-tab',
				challenge: '',
				chlg: {
					now: 0,
					diff: 0,
					end: 0,
					minutes: 0,
					seconds: 0,
					hours: 0,
					days: 0,
					gap: 0,
					timerDisplay: '',
					reward: 0,
					reset: 0,
					goal: 0,
					period: 0,
					locRef: '',
					challengeDailyData: '',
					newRequest: false,
					timer: null
				}
            }
        },
        
        methods: {
			fetchJson() {
				extern.requestJson('data/shellNews.json', (data) => {
					if (crazyGamesActive) {
						const newNews = data.filter((item, idx) => {
							if (item.hideOnCrazyGames !== null && item.hideOnCrazyGames) {
								return false;
							} else {
								return true;
							}
						});

						this.news = newNews;
					}
					this.news = data;

				});
				extern.requestJson('data/shellYouTube.json', (data) => this.youTube = data);
				extern.requestJson('data/twitchStreams.json', (streams) => {
						
						streams.sort((a, b) => {
							return b.viewers - a.viewers;
						});

						let streamsArray = streams.map(stream => {
							return {
								name: stream.name,
								viewers: stream.viewers,
								link: 'https://twitch.tv/' + stream.name,
								image: dynamicContentPrefix + 'data/img/twitchAvatars/' + stream.avatar
							}
						})

						this.twitch =  streamsArray;
				});

			},
            selectTab: function (id, playSound) {
				this.currentTab = id;
				extern.playerChallenges.resizeAllText();
            },
            cancelRotate() {
                clearTimeout(this.rotateTimeout);
				this.autoRotateTabs();
            },
			rotateTab() {
				let currentIdx = this.mediaTabs.findIndex(tab => tab.id === this.currentTab);
					if (currentIdx + 1 > this.mediaTabs.length - 1) {
					this.selectTab(this.mediaTabs[0].id);
				} else {
					this.selectTab(this.mediaTabs[currentIdx + 1].id);
				}
				// start the countdown again
				this.autoRotateTabs();
			},
            autoRotateTabs() {
				if (this.currentTab === "challenges-tab") {
					var delay = 14000;
				} else {
					var delay = this.delay;
				}
				this.rotateTimeout = setTimeout(() => this.rotateTab(), delay);
            },
			onTabClicked(id) {
				this.selectTab(id);
				//click cancels the rotation and restarts it
				this.cancelRotate();
				ga('send', 'event', 'media-tabs', 'click', id);
				BAWK.play('ui_toggletab');
			},
            randomTabSelect() {
				this.selectTab(this.mediaTabs[Math.floor(Math.random() * this.mediaTabs.length)].id);
            },

			timeFormat(time) {
				return time < 10 ? '0' + time : time;
			},
			timer() {
				this.chlg.gap = Math.floor(this.end - (Math.trunc(Date.now()/1000)));

				if (this.chlg.gap < 0) {
					this.chlg.gap = 0;

					if (!this.newRequest) {
						this.newRequest = true;
						clearInterval(this.chlg.timer);
						this.chlg.timer = null;
						extern.playerChallenges.getNew();
					}
				}

				let hoursLeft = 0;
				let minutesLeft = 0;

				this.chlg.days = Math.floor(this.chlg.gap/24/60/60);
				hoursLeft = Math.floor((this.chlg.gap) - (this.chlg.days*86400));
				this.chlg.hours = this.timeFormat(Math.floor(hoursLeft/3600));
				minutesLeft = Math.floor((hoursLeft) - (this.chlg.hours*3600));
				this.chlg.minutes = this.timeFormat(Math.floor(minutesLeft/60));
				this.chlg.seconds = this.timeFormat(this.chlg.gap % 60);
			},
			challengeReroll(id) {
				extern.playerChallenges.reroll(id);
			},
			// Adds the Challenges tab if it doesn't exist
			addChallengesTab() {
				const exists = this.mediaTabs.find(tab => tab.id === 'challenges-tab');
				if (!exists) {
					this.mediaTabs.unshift({
						id: 'challenges-tab',
						name: 'Challenges',
						icon: 'fas fa-trophy'
					});
				}
			},

			// Removes the Challenges tab if it exists
			removeChallengesTab() {
				this.mediaTabs = this.mediaTabs.filter(tab => tab.id !== 'challenges-tab');
			},

        },
		computed: {
			tabName() {
				switch (this.currentTab) {
					case 'news-tab':
						return this.loc.home_latestnews;
						break;
					case 'twitch-tab':
						return 'Twitch'
						break;
					case 'video-tab':
						return 'YouTube'
						break;
					case 'challenges-tab':
						return this.loc.challenges;
						break;
					default:
						break;
				}
			},

			newsItems() {
				// crazyGamesActive = true;
				if (crazyGamesActive) {
					const newNews = this.newsfeedItems.filter((item, idx) => {
						if (item.hideOnCrazyGames !== null && item.hideOnCrazyGames) {
							return false;
						} else {
							return true;
						}
					});

					return newNews;
				}
				return this.newsfeedItems;
			},

			hasChlgs() {
				return Array.isArray(this.challenges) && this.challenges.length > 0 ? true : false;
			},
			tabContentStyle() {
				if (this.currentTab !== 'challenges-tab') {
					return 'ss_paddingright ss_paddingleft';
				}
			},
			newsContainerStyle() {
				if (this.currentTab === 'challenges-tab') {
					return 'overflow-hidden';
				} else {
					return 'v_scroll';
				}
			}
		},
		watch: {
			firebaseId(val) {
				if (val) {
					this.addChallengesTab();
					this.selectTab('challenges-tab');
					this.cancelRotate();
				} else {
					this.removeChallengesTab();
					this.randomTabSelect();
				}
			},

			challenges(val) {
				if (val.length > 0) {
					this.$nextTick(() => {
						const challengeHeight = this.$refs.newsContainer.querySelector('.player-challenges-container');
						
						if (challengeHeight !== null) {
							const computedStyle = window.getComputedStyle(this.$refs.newsContainer);
							const baseFontSize = parseFloat(computedStyle.fontSize);
							const heightInPixels = challengeHeight.clientHeight;
							const heightInEms = heightInPixels / baseFontSize;
							
							this.$refs.newsContainer.style.height = heightInEms + 'em';
						}
					});
				}
			}
		}
    };
</script><template id="music-widget">
    <div v-if="isMusic" class="music-widget roundme_md" :class="[!show ? hideClass : '']">
        <div v-if="theAudio" class="music-widget--wrapper flex flex-nowrap">
            <figure class="music-widget--content">
                <header class=" roundme_md">
                    <h3 class="music-widget--now-playing">{{ loc.musicwidget_now_playing }}</h3>
                </header>

                <figcaption class="music-widget--content-wrapper">
                    <h4 class="music-widget--album-title">{{ serverTracks.artist }}</h4>
                </figcaption>
                <figcaption class="music-widget--content-wrapper">
                    <p v-if="serverTracks.url" class="music-widget--song-title"><a @click="gaSendEvent('click-track', getTitleAlbum)" :href="serverTracks.url" :title="theTitleAttr" target="_blank">{{ getTitleAlbum }}</a></p>
                    <p v-else class="music-widget--song-title">{{ getTitleAlbum }}</p>
                </figcaption>
                <div v-if="volumeSlider" v-for="t in settingsUi.adjusters.music" class="music-widget--volume-control nowrap">
                    <slider-component :loc="loc" :loc-key="t.locKey" :control-id="t.id" :control-value="t.value" :min="t.min" :max="t.max" :step="t.step" :multiplier="t.multiplier" @setting-adjusted="volumeControl"></slider-component>
                </div>
            </figure>
            <div class="music-widget--cover-image music-widget--cover-controls roundme_md">
                <template v-if="serverTracks.url">
                    <a v-if="serverTracks.albumArt" @click="gaSendEvent('click-albumArt', getTitleAlbum)" :href="serverTracks.url" :title="theTitleAttr" class="ss-absolute" target="_blank"><img :src="serverTracks.albumArt" class="roundme_md ss-absolute" :alt="serverTracks.album" /></a>
                </template>
                <template v-else>
                    <img v-if="serverTracks.albumArt" :src="serverTracks.albumArt" class="ss-absolute roundme_md" alt="Album cover art for" :alt="serverTracks.album" />
                </template>
                <button v-if="playBtn" @click="playAudio">
                    <i v-if="playing"  class="music-widget--cover-control-icon music-widget--cover-control-pause far fa-pause-circle fa-2x"></i>
                    <i v-if="!playing" class="music-widget--cover-control-icon music-widget--cover-control-pause far fa-play-circle fa-2x"></i>
                </button>
            </div>
            <div class="music-widget--sponsor">
                <a @click="gaSendEvent('click-sponsor', sponsor.name)" v-if="sponsor" :href="sponsor.link" :title="getSponsorTitleAttr" target="_blank"><img :src="getSponsorImg" class="music-widget--sponsor-icon" :alt="sponsor.name" /><span class="hideme">{{sponsor.name}}</span></a>
                <button v-if="settings" @click="openSettings" class="music-widget--sponsor--settings-btn"><i class="fas fa-cog"></i><span class="hideme">Music Settings</span></button>
                <button class="music-widget--sponsor--settings-btn" @click="toggleMusic"><i class="fas" aria-hidden="true" :class="togglePlayStopIcon"></i><span class="hideme">Music</span></button>
            </div>
        </div>
    </div>
</template>


<script>

    const createMusicWidget = templateId => {

        return {
            template: '#music-widget',
            props: ['loc','volumeSlider', 'playBtn', 'settings', 'settingsUi', 'show'],
            components: {
                'slider-component': comp_settings_adjuster
            },

            data () {
                return vueData.music;
            },

            mounted () {
                this.theAudio = document.getElementById('theAudio');
            },

            methods: {

                loadVolume() {
                    this.$nextTick(() => {
                        this.theAudio.volume = Number(this.settingsUi.adjusters.music[0].value);
                    });
                },
                getAudioServer() {
                    if (parsedUrl.dom == 'localhost' || parsedUrl.dom == 'dev' || parsedUrl.dom == 'localshelldev') {
                        var url = 'uswest2-music.shellshock.io';
                    }
                    else {
                        var server = vueApp.regionList.filter(server => region.locKey === vueApp.currentRegionLocKey)[0];
                        var url = server.subdom.slice(0, -1) + '-music.' + parsedUrl.dom + '.' + parsedUrl.top;
                    }

                    this.musicSrc = 'https://' + url + '/shellshock.ogg';
                },
                setIndex(k) {
                    this.$nextTick(() => {
                        this.play();
                    })
                    this.currIndex = k;
                },

                play() {
                    if (!this.isMusic) return;
                    this.getAudioServer();
                },

                playMusic() {
                    // var audio = this.theAudio;
                    this.theAudio.src = this.musicSrc;

                    console.log('Play Music');

                    clearInterval(this.timer);

                    this.theAudio.play()
                        .then( // Returns a Promise
                            () => { // Success
                                this.playing = true;
                                this.loadVolume();
                                this.duration = this.theAudio.duration;
                                this.theAudio.addEventListener('stalled', () => this.isMusic = false);
                                
                            },
                            () => { // Fail
                                // What to do... just try again after a few seconds, I guess?
                                setTimeout(() => this.play(), 2000);
                            }
                        );
                },

                pause() {
                    this.playing = false;
                    this.theAudio.pause();
                    clearInterval(this.timer);
                },
                /*
                next() {
                    if (this.currIndex < this.tracks.length - 1) {
                        this.currIndex++;
                    } else {
                        this.currIndex = 0;
                    }
                },

                prev() {
                    if (this.currIndex > 0) {
                        this.currIndex--;
                    } else {
                        this.currIndex = this.tracks.length - 1;
                    }
                },
                */
                playOnce() {
                    if (this.playing) return;
                    return this.play();
                },

                playAudio() {
                    if (this.theAudio.paused) {
                        this.play();
                    } else {
                        this.pause();
                    }
                },

                openSettings() {
                    vueApp.showSettingsPopup();
                    vueApp.onSettingsPopupSwitchTabMisc();
                    this.gaSendEvent('click', 'widgetOpenSettings');
                },

                volumeControl(id, value) {
                    extern.setMusicVolume(value);
                    vueApp.onSettingsQuickSave();
                },

                hideMe() {
                    return this.$refs.id.classList.addClass('fade-out-3');
                },
                showMe() {
                    this.show = true;
                    setTimeout(() => this.show = false, 2000);
                },
                gaSendEvent(action, label) {
                    action = action || '';
                    label = label || '';
                    return ga('send', 'event', 'music', action, label);
                },
                toggleMusic() {
                    if (this.playing) {
                        this.theAudio.removeEventListener('stalled', () => this.isMusic = false);
                        this.playing = false;
                        this.pause();
                        this.musicSrc = '';
                        this.theAudio.removeAttribute('src');
                        extern.setMusicStatus(false);
                        this.gaSendEvent('toggleMusic', 'off');
                        return;
                    }
                    this.theAudio.src = '';
                    this.play();
                    extern.setMusicStatus(true);
                    this.gaSendEvent('toggleMusic', 'on');
                },
                changeVolume(val) {
                    this.theAudio.volume = val;
                }
            },

            watch: {
                'currIndex': {
                    handler() {
                        this.$nextTick(() => {
                            this.play();
                        })
                    }
                },
                serverTracks(val) {
                    let sponsor = this.sponsors.filter(sponsor => sponsor.id === val.sponsor);
                    this.sponsor = sponsor.length || sponsor.length > 0 ? sponsor[0] : '';
				},
                musicSrc(val) {
                    if (val) {
                        this.playMusic();
                    }
                },
            },
            computed: {
                theTitleAttr() {
                    return 'Read more about ' + this.serverTracks.title;
                },
                getTitleAlbum() {
                    return this.serverTracks.title + ' - ' + this.serverTracks.album;
                },
                getSponsorImg() {
                    if (!this.sponsor) {
                        return;
                    }
                    return 'data/img/sponsor/' + this.sponsor.id + this.sponsor.imageExt;
                },
                getSponsorTitleAttr() {
                    return 'See more about our sponsor ' + this.sponsor.name;
                },
                togglePlayStopIcon() {
                    return this.playing ? 'fa-stop-circle' : 'fa-play-circle';
                },
            },
        };
    };
    // Register component globally
    Vue.component('music-widget', createMusicWidget('#music-widget'));
</script><script id="main-sidebar-template" type="text/x-template">
	<div id="screens-menu" v-if="isGamePaused" class="screens-menu box_relative">
		<!-- logo -->
		<div id="logo" class="box_relative">
			<a href="https://www.shellshock.io" @click="onLogoClick"><img class="home-screen-logo" :src="logo" @click="onLogoClick"></a>
			<!-- <img v-if="eggOrg" class="egg-org-logo" src="img/egg-org/logo_EggOrg.svg"> -->
			<button v-if="inGame && currentScreen !== screens.game" class="ss_button btn_md btn_green bevel_green box_relative box_absolute screens-menu-btn-return f_row align-items-center gap-sm justify-content-center text-uppercase" @click="onBackClick">{{ loc.p_pause_game_on }} <icon class="fill-white shadow-filter" name="ico-backToGame"></icon></button>
		</div>
		<div class="box_relative">
			<player-name v-if="currentScreen === screens.home" :loc="loc" :player-name="playerName" :picked-game-type="pickedGameType" :current-screen="currentScreen" :screens="screens"></player-name>
			<!-- main-menu -->
			<div id="main-menu" class="main-menu box_relative" :class="{'is-home-screen' : currentScreen === screens.home}">
				<menu class="nospace">
					<ul class="nospace text-left list-no-style display-grid gap-sm">
						<menu-item v-for="(item, idx) in menuItems" :loc="loc" :key="idx" :item="item" :current-screen="currentScreen" :screens="screens" :mode="mode" :currentMode="currentMode" :is-paused="inGame" @previous-screen="previousScreen"></menu-item>
					</ul>
				</menu>
			</div>
		</div>
	</div>
	<!-- main-sidebar -->
</script>

<script id="main-menu-item" type="text/x-template">
	<li :class="listCls">
		<button class="fullwidth main-menu-button text-left font-sigmar roundme_sm text-uppercase box_relative f_row align-items-center" @click="onMenuItemClick" :class="itemCls">
			<svg class="centered" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 356.331 71"><path d="M293.124 71H4V9h340.08c11.045 0 16.429 13.48 8.42 21.084L321.213 59.79A40.795 40.795 0 0 1 293.123 71Z" style="fill-rule:evenodd;fill:#1192bc;opacity:.5"/><path class="main-nav-item-bg" d="M289.124 64H2V2h338.08c11.045 0 16.429 13.48 8.42 21.084L317.213 52.79A40.795 40.795 0 0 1 289.123 64Z" style="stroke-miterlimit:10;stroke-width:4px;fill-rule:evenodd"/></svg>
			<icon :name="getIcon" class="menu-icon"></icon>
			{{ loc[locKey] }}
		</button>
	</li>
</script>

<script id="chw-bubble-template" type="text/x-template">
	<div ref="chw-home-timer" v-show="!isPoki && firebaseId" class="chw-home-timer display-grid grid-column-1-2 align-items-center box_absolute gap-1 " :class="chwHomeTimerCls">
		<div>
			<img class="chw-home-timer-chick" :src="chwChickSrc">
		</div>
		<div class="display-grid align-items-center bg_white chw-circular-timer-container box_relative" :class="chwClass">
			<div v-show="chwShowTimer" class="chw-home-screen-timer"></div>
			<!-- #chw-circular-timer-outer -->
			<div>
				<p class="chw-circular-timer-countdown nospace">
					<span class="chw-pie-remaining text-center chw-msg chw-r-msg">{{ remainingMsg }}</span>
					<span v-show="chwShowTimer" class="chw-pie-num chw-pie-hours"></span><span v-show="chwShowTimer" class="chw-pie-num chw-pie-mins"></span><span v-show="chwShowTimer" class="chw-pie-num chw-pie-secs"></span>
				</p>
				<button v-if="ready && !hasChwPlayClicked && !error" class="ss_button btn_sm btn_yolk bevel_yolk" @click="playIncentivizedAd">{{ playAdText }}</button>
			</div>
		</div>
	</div>
	<!-- .chw-home-timer -->
</script>

<script>
var COMPCHWBUBBLE = {
	template: '#chw-bubble-template',
	components: {
	},

	props: ['loc', 'isPoki', 'firebaseId', 'limitReached', 'ready', 'error', 'counter', 'hasChwPlayClicked', 'imgs'],
	data: function() {
		return {
		}
	},		
	methods: {
		showNuggyPopup() {
			vueApp.showChicknWinnerPopup();
		},
		playIncentivizedAd(e) {
			if (this.showAdBlockerVideoAd) {
				return;
			}
			if (!this.ready || this.hasChwPlayClicked) {
				e.preventDefault();
				return;
			}
			ga('send', 'event', 'Chickn Winner', 'Free eggs btn', 'click-home');

			this.hasChwPlayClicked = true;
			vueApp.loadNuggetVideo();
			vueApp.chicknWinnerNotReady();
		},
		// needs emit
		chwShowCycle() {
			this.chwHomeEl = document.querySelector('.chw-home-timer');
			if (this.chwHomeEl) {
			this.chwHomeTimer = setInterval(() => {
				this.chwHomeEl.classList.toggle('active');
				}, this.chwActiveTimer);
			}
		},
	},
	computed: {
		playAdText() {
			if (this.ready && this.counter === 0) {
				return this.loc.chw_btn_free_reward;
			} else {
				return this.loc.chw_btn_free_reward;
			}
		},
		chwClass() {
			if (this.limitReached || this.error) {
				return 'grid-column-1-eq';
			} else {
				if (this.ready) {
					return 'grid-column-1-eq';
				} else {
					return 'grid-column-1-2';
				}
			}
		},
		chwHomeTimerCls() {
			//{'chw-home-screen-max-watched': limitReached}
			if (this.limitReached) {
				return 'chw-home-screen-max-watched';
			} else {
				if (this.ready) {
					return 'is-ready active';
				} else {
					return 'not-ready';
				}
			}
		},
		chwChickSrc() {
			if (this.limitReached || this.error) {
				return 'img/chicken-nugget/chickLoop_daily_limit.svg';
			} else {
				if (!this.ready) {
					return 'img/chicken-nugget/chickLoop_sleep.svg';
				} else {
					return 'img/chicken-nugget/chickLoop_speak.svg';
				}
			}
		},
		chwShowTimer() {
			if (this.limitReached) {
				// this.chwStopCycle();
				return false;
			} else {
				if (this.ready) {
					this.chwShowCycle();
					return false;
				} else {
					// this.chwStopCycle();
					return true;
				}
			}
		},
		remainingMsg() {
			if (this.error) {
				return this.loc.chw_error_text;
			}
			if (this.limitReached && this.counter > 0) {
				return this.loc.chw_daily_limit_msg;
			}
			if (this.ready) {
				if (this.counter === 0) {
					return this.loc.chw_ready_msg;
				} else {
					return this.loc.chw_cooldown_msg;
				}
			} else {
				return this.loc.chw_time_until;
			}
		},
		progressBarWrapClass() {
			if (this.ready) {
				return 'chw-progress-bar-wrap-complete';
			}
		},
	},
	watch: {
	}
};
</script>
<script>
const MainMenuItem = {
	template: '#main-menu-item',
	props: ['loc', 'item', 'currentScreen', 'screens', 'mode', 'currentMode', 'isPaused'],
	data: function() {
		return {
			inGame: false
		}
	},
	methods: {
		onMenuItemClick() {
			if (this.item.screen === this.currentScreen && !this.item.mode) {
				return;
			}
			this.$emit('previous-screen', this.currentScreen);

			switch (this.item.screen) {
				case this.screens.home:
					if (!extern.inGame) {
						if (this.currentScreen === this.screens.equip) {
							vueApp.onBackClick();
						}
						vueApp.switchToHomeUi();
					} else {
						vueApp.onHomeClicked();
						ga('send', 'event','respawn-popup', 'click', 'quit');
					}
					break;
				case this.screens.equip:

					// this should only show once a day
					setTimeout(() => vueApp.showChickenPopup(), 500);

					if (this.item.mode.includes(this.mode.inventory)) {
						ga('send', 'event', extern.inGame ? 'respawn-popup' : 'home', 'click', 'inventory');
						vueApp.openEquipSwitchTo(this.mode.inventory);
					} else {
						ga('send', 'event', extern.inGame ? 'respawn-popup' : 'home', 'click', 'shop');
						vueApp.openEquipSwitchTo(this.mode.shop);
					}
					if (extern.inGame) {
						setTimeout(() => {
							extern.resize();
						}, 200);
					}
					break;
				case this.screens.profile:
					if (this.currentScreen === this.screens.equip) {
						vueApp.onBackClick();
					}
					ga('send', 'event', extern.inGame ? 'respawn-popup' : 'home', 'click', 'profile');
					vueApp.switchToProfileUi();
					break;
				case this.screens.photoBooth: 
					vueApp.switchToPhotoBoothUi();
					break;
				default:
					break;
			}
		},
		// showOn(item) {
		// 	if (item.locKey === 'account_title_home' && extern.inGame) {
		// 		return false;
		// 	} else {
		// 		return item.showOn.alwasyOn || (!item.showOn.alwasyOn && item.showOn.screen === this.currentScreen);
		// 	}
		// }
	},
	computed: {
		locKey() {
			if ((this.isPaused) && this.item.locKey === 'account_title_home') {
				return 'p_pause_quit';
			} else {
				return this.item.locKey;
			}
		},
		iconCls() {
			return `${this.item.icon}`;
		},
		listCls() {
			return `${this.loc[this.item.locKey].toLowerCase().replace(/\s/g, '') + '-menu-item'}`
		},
		getIcon() {
			return `${this.item.icon}`;
		},
		itemCls() {
			if (this.item.mode.length === 0) {
				if (this.item.screen === this.currentScreen) {
					return 'current-screen';
				}
			} else if (this.item.mode.includes(this.currentMode) && this.item.screen === this.currentScreen) {
				return 'current-screen';
			}
		},
	},

	watch: {
		currentScreen() {
			this.inGame = extern.inGame;
		}
	}
};
</script><script id="player-name-input" type="text/x-template">
	<input id="player-name" name="name" :value="playerName" v-bind:placeholder="loc.play_enter_name" @change="onNameChange($event)" v-on:keyup="onPlayerNameKeyUp($event)" :class="cls">
</script>

<script>
const PlayerNameInput = {
	template: '#player-name-input',
	props: ['loc', 'playerName', 'pickedGameType', 'currentScreen', 'screens'],
	data: function() {
		return {

		}
	},
	methods: {
		onNameChange (event) {
			console.log('name changed to: ' + event.target.value);
			console.log('play name event handler');
			vueApp.setPlayerName(event.target.value);
			BAWK.play('ui_onchange');
		},
		onPlayerNameKeyUp (event) {
			event.target.value = extern.filterUnicode(event.target.value);
			event.target.value = extern.fixStringWidth(event.target.value);
			event.target.value = event.target.value.substring(0, 128);

			// Send username to server to start the game!
			if (event.code == "Enter" || event.keyCode == 13) {
				if (vueData.playerName.length > 0) {
					if (vueData.playerName.length > 0) {
						vueApp.externPlayObject(vueData.playTypes.joinPublic, this.pickedGameType, this.playerName, -1, '');
					}
				}
			}
		},
	},
	computed: {
		cls() {
			return this.currentScreen === this.screens.profile ? 'font-sigmar text-shadow-black-40 text_white box_relative profile-name' : 'box_absolute ss_field font-nunito ss_name';
		}
	}

};
</script>
<script>
var COMPMAINSIDE = {
	template: '#main-sidebar-template',
	components: {
		'menu-item': MainMenuItem,
		'player-name': PlayerNameInput
	},

	props: ['loc', 'playerName', 'menuItems', 'currentScreen', 'screens', 'mode', 'currentMode', 'inGame', 'isGamePaused', 'pickedGameType'],
	data: function() {
		return {
			itemSelected: 0,
			logo: shellLogo,
		}
	},		
	methods: {
		onLogoClick(e) {
			if (extern.inGame) {
				e.preventDefault();
				return;
			}
			BAWK.play('ui_click')
		},
		onBackClick() {
			if (this.currentScreen === this.screens.equip) {
				vueApp.onBackClick();
			}
			setTimeout(() => {
				extern.resize();
			}, 1);
			vueApp.hideTitleScreenAd();
			vueApp.switchToGameUi();
			vueApp.showGameMenu();
		},
		previousScreen(screen) {
			this.$emit('previous-screen', screen);
		}
	},
};
</script><script id="profile-screen-template" type="text/x-template">
	<div id="mainLayout" class="profile-content-wrap">
		<section class="profile-page-content roundme_sm ss_marginright bg_blue6 common-box-shadow">
			<section class="display-grid grid-column-2-eq paddings_xl bg_blue3 gap-sm">
				<header class="f_row align-items-center">
					<section>
						<h1 class="text-shadow-black-40 text_white nospace">{{ playerName }}</h1>
						<!-- <player-name :loc="loc" :player-name="playerName" :picked-game-type="currentGameType" :current-screen="showScreen" :screens="screens"></player-name> -->
						<!--button v-if="showTwitchEvent" class="ss_button btn-twitch bevel_twitch justify-content-center btn_sm box_relative f_row gap-sm align-items-center" @click="onTwitchDropsClick"><i aria-hidden="true" class="fab fa-twitch"></i> {{ isTwitchLinked }}</button>-->
					</section>
				</header>
				<aside class="justify-self-end text-right">
					<p class="account-create-date nospace text_white opacity-7" v-html="accountStatus"></p>
					<button id="account-button" @click="onAccountBtnClicked" class="ss_button btn_md font-800" :class="accountBtnCls">{{ accountBtnTxt }}</button>
				</aside>
			</section>
			<section class="profile-stat-wrap center_h paddings_xl box_relative">
				<div v-if="ui.game.stats.loading" class="stats-loading box_absolute">
					<strong><span class="text_blue5 font-size-md text-uppercase">Stats loading... <i class="fas fa-spinner fa-spin"></i></span></strong>
				</div>
				<stats-content :loc="loc" :stats-monthly="statsCurrent" :stats-lifetime="statsLifetime" :kdrLifetime="kdrLifetime" :showLifetime="ui.profile.statTab" :eggs-spent="eggsSpent" :eggs-spent-monthly="eggsSpentMonthly" :challenges-claimed="claimed"></stats-content>
			</section>
		</section>
	</div>
	<!-- .main-content -->
</script>

<script id="stats-stats-template" type="text/x-template">
	<div class="stats-box">
		<div v-if="renderReady">
			<header class="display-grid stats-grid-other stat-grid-main-header stat-wrapper ss_paddingright_lg ss_paddingleft_xl">
				<div><h3 class="text-shadow-black-40 text_white nospace">Stats</h3></div>
				<div class="text-center"><h3 class="text-shadow-black-40 text_white nospace">{{ loc.stat_lifetime }}</h3></div>
				<div class="text-center"><h3 class="text-shadow-black-40 text_white nospace">{{ loc.stat_monthly }}</h3></div>
			</header>
			<div class="stats-container box_relative center_h ss_margintop_sm">
				<div class="bg_blue2 roundme_lg ss_marginright_sm">
					<div class="stat-wrapper paddings_lg">
						<section v-if="renderReady" class="stat-columns">
							<stat-item :loc="loc" :stat="{'name': 'kills', 'lifetime': statsLifetime.kills.total, 'current': statsMonthly.kills.total }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'deaths', 'lifetime': statsLifetime.deaths.total, 'current': statsMonthly.deaths.total }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'streak', 'lifetime': statsLifetime.streak, 'current': statsMonthly.streak }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'kdr', kdr: true, 'lifetime': [statsLifetime.kills.total, statsLifetime.deaths.total], 'current': [statsMonthly.kills.total, statsMonthly.deaths.total] }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'stat_kotc_wins', 'lifetime': statsLifetime.gameType.kotc.wins, 'current': statsMonthly.gameType.kotc.wins }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'stat_kotc_captured', 'lifetime': statsLifetime.gameType.kotc.captured, 'current': statsMonthly.gameType.kotc.captured }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'stat_eggs_spent', 'lifetime': eggsSpent, 'current': eggsSpentMonthly }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'stat_public_kdr', kdr: true, 'lifetime': [statsLifetime.kills.mode.public, statsLifetime.deaths.mode.public], 'current': [statsMonthly.kills.mode.public, statsMonthly.deaths.mode.public] }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'stat_private_kdr', kdr: true, 'lifetime': [statsLifetime.kills.mode.private, statsLifetime.deaths.mode.private], 'current': [statsMonthly.kills.mode.private, statsMonthly.deaths.mode.private] }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'stat_fa_kdr', kdr: true, 'lifetime': [statsLifetime.kills.gameType.ffa, statsLifetime.deaths.gameType.ffa], 'current': [statsMonthly.kills.gameType.ffa, statsMonthly.deaths.gameType.ffa] }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'stat_teams_kdr', kdr: true, 'lifetime': [statsLifetime.kills.gameType.team, statsLifetime.deaths.gameType.team], 'current': [statsMonthly.kills.gameType.team, statsMonthly.deaths.gameType.team] }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'stat_ctf_kdr', kdr: true, 'lifetime': [statsLifetime.kills.gameType.spatula, statsLifetime.deaths.gameType.spatula], 'current': [statsMonthly.kills.gameType.spatula, statsMonthly.deaths.gameType.spatula] }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'stat_kotc_kdr', kdr: true, 'lifetime': [statsLifetime.kills.gameType.kotc, statsLifetime.deaths.gameType.kotc], 'current': [statsMonthly.kills.gameType.kotc, statsMonthly.deaths.gameType.kotc] }"></stat-item>
						</section>
					</div>
		
					<header class="display-grid stats-grid-other stat-grid-main-header stat-wrapper ss_paddingright_lg ss_paddingleft_xl ss_paddingtop_sm ss_paddingbottom_sm">
						<div><h4 class="nospace">{{ loc.stat_game_mode }}</h4></div>
						<div class="text-center display-grid grid-auto-flow-column" style="margin-left: 0.9em;"><h4 class="nospace">{{ loc.kills }}</h4> <h4 class="nospace">{{ loc.deaths }}</h4></div>
						<div class="text-center display-grid grid-auto-flow-column" style="margin-left: 0.9em;"><h4 class="nospace">{{ loc.kills }}</h4> <h4 class="nospace">{{ loc.deaths }}</h4></div>
					</header>
					<div class="stat-wrapper paddings_lg">
						<section v-if="renderReady" class="stat-columns">
							<stat-item :loc="loc" :stat="{'name': 'stat_public', 'lifetime': [statsLifetime.kills.mode.public, statsLifetime.deaths.mode.public], 'current': [statsMonthly.kills.mode.public, statsMonthly.deaths.mode.public] }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'stat_private', 'lifetime': [statsLifetime.kills.mode.private, statsLifetime.deaths.mode.private], 'current': [statsMonthly.kills.mode.private, statsMonthly.deaths.mode.private] }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'gametype_ffa', 'lifetime': [statsLifetime.kills.gameType.ffa, statsLifetime.deaths.gameType.ffa], 'current': [statsMonthly.kills.gameType.ffa, statsMonthly.deaths.gameType.ffa] }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'gametype_teams', 'lifetime': [statsLifetime.kills.gameType.team, statsLifetime.deaths.gameType.team], 'current': [statsMonthly.kills.gameType.team, statsMonthly.deaths.gameType.team] }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'gametype_ctf', 'lifetime': [statsLifetime.kills.gameType.spatula, statsLifetime.deaths.gameType.spatula], 'current': [statsMonthly.kills.gameType.spatula, statsMonthly.deaths.gameType.spatula] }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'gametype_king', 'lifetime': [statsLifetime.kills.gameType.kotc, statsLifetime.deaths.gameType.kotc], 'current': [statsMonthly.kills.gameType.kotc, statsMonthly.deaths.gameType.kotc] }"></stat-item>
						</section>
					</div>
		
					<header class="display-grid stats-grid-other stat-grid-main-header stat-wrapper ss_paddingright_lg ss_paddingleft_xl ss_paddingtop_sm ss_paddingbottom_sm">
						<div><h4 class="nospace">{{ loc.stat_weapons }}</h4></div>
						<div class="text-center display-grid grid-auto-flow-column" style="margin-left: 0.9em;"><h4 class="nospace">{{ loc.kills }}</h4> <h4 class="nospace">{{ loc.deaths }}</h4></div>
						<div class="text-center display-grid grid-auto-flow-column" style="margin-left: 0.9em;"><h4 class="nospace">{{ loc.kills }}</h4> <h4 class="nospace">{{ loc.deaths }}</h4></div>
					</header>
					<div class="stat-wrapper paddings_lg">
						<section v-if="renderReady" class="stat-columns">
							<stat-item :loc="loc" :stat="{'name': 'item_type_3_0', 'lifetime': [statsLifetime.kills.dmgType.eggk, statsLifetime.deaths.dmgType.eggk], 'current': [statsMonthly.kills.dmgType.eggk, statsMonthly.deaths.dmgType.eggk] }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'item_type_3_1', 'lifetime': [statsLifetime.kills.dmgType.scrambler, statsLifetime.deaths.dmgType.scrambler], 'current': [statsMonthly.kills.dmgType.scrambler, statsMonthly.deaths.dmgType.scrambler] }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'item_type_3_2', 'lifetime': [statsLifetime.kills.dmgType.ranger, statsLifetime.deaths.dmgType.ranger], 'current': [statsMonthly.kills.dmgType.ranger, statsMonthly.deaths.dmgType.ranger] }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'item_type_3_3', 'lifetime': [statsLifetime.kills.dmgType.rpegg, statsLifetime.deaths.dmgType.rpegg], 'current': [statsMonthly.kills.dmgType.rpegg, statsMonthly.deaths.dmgType.rpegg] }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'item_type_3_4', 'lifetime': [statsLifetime.kills.dmgType.whipper, statsLifetime.deaths.dmgType.whipper], 'current': [statsMonthly.kills.dmgType.whipper, statsMonthly.deaths.dmgType.whipper] }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'item_type_3_5', 'lifetime': [statsLifetime.kills.dmgType.crackshot, statsLifetime.deaths.dmgType.crackshot], 'current': [statsMonthly.kills.dmgType.crackshot, statsMonthly.deaths.dmgType.crackshot] }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'item_type_3_6', 'lifetime': [statsLifetime.kills.dmgType.trihard, statsLifetime.deaths.dmgType.trihard], 'current': [statsMonthly.kills.dmgType.trihard, statsMonthly.deaths.dmgType.trihard] }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'weapon_cluck_9mm', 'lifetime': [statsLifetime.kills.dmgType.pistol, statsLifetime.deaths.dmgType.pistol], 'current': [statsMonthly.kills.dmgType.pistol, statsMonthly.deaths.dmgType.pistol] }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'item_type_6', 'lifetime': [statsLifetime.kills.dmgType.grenade, statsLifetime.deaths.dmgType.grenade], 'current': [statsMonthly.kills.dmgType.grenade, statsMonthly.deaths.dmgType.grenade] }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'item_type_7', 'lifetime': [statsLifetime.kills.dmgType.melee, statsLifetime.deaths.dmgType.melee], 'current': [statsMonthly.kills.dmgType.melee, statsMonthly.deaths.dmgType.melee] }"></stat-item>
							<stat-item :loc="loc" :stat="{'name': 'death_by_fall', 'lifetime': ['N/A', statsLifetime.deaths.dmgType.fall], 'current': ['N/A', statsMonthly.deaths.dmgType.fall] }"></stat-item>
						</section>
					</div>
				</div>
				<div class="bg_blue2 roundme_lg ss_marginright_sm ss_margintop_sm">
					<div class="stat-wrapper paddings_lg">
						<h3 class="text-shadow-black-40 text_white nospace">{{ loc.challenges_completed }}</h3>
						<div class="stat font-600">
							<div class="roundme_sm ss_paddingleft ss_paddingtop_micro ss_marginbottom_sm">
								<p class="nospace text_white">{{ loc.total }}: {{ challengesClaimed.total }}</p>
							</div>
						</div>
						<div class="stat font-600">
						<div class="roundme_sm ss_paddingleft ss_paddingtop_micro ss_marginbottom_sm">
							<p class="nospace text_white">{{ loc.unique }}: {{ challengesClaimed.unique }}</p>
						</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</script>

<script id="the-stat-template" type="text/x-template">
	<section class="stat display-grid font-600" :class="statWrapper">
		<div class="text_white roundme_sm_top-bottom_right ss_paddingleft ss_paddingtop_micro ss_marginbottom_sm"><p>{{ statTitle }}</p></div>
		<div class="text-center text_white roundme_sm_top-bottom_left ss_paddingleft ss_paddingtop_micro ss_marginbottom_sm ss_marginright_sm" :class="lifetimeCls" v-html="statLifetime"></div>
		<div class="text-center text_white roundme_sm ss_paddingleft ss_paddingtop_micro ss_marginbottom_sm" :class="currentCls" v-html="statMonthly"></div>
	</section>
</script>

<script>
var StatTemplate = {
    template: '#the-stat-template',
    props: ['loc', 'stat'],
    data: function () {
        return {
			lifetimeCls: '',
			currentCls: '',
		}
    },
    methods: {
		statName(key) {
			if (key=== 'eggk') {
				key= 'eggK-47';
			}
			return key.toUpperCase();
		},
		kdr(kills, deaths) {
			return Math.floor((kills / Math.max(deaths, 1)) * 100) / 100;
		},
		setupStat(stat) {
			if (this.stat.kdr !== undefined && stat.length !== undefined) {
				return this.kdr(stat[0], stat[1]);
			} else if (stat && stat.length !== undefined) {
				return `<div>${stat[0]}</div> <div>${stat[1]}</div>`;
			} else {
				return stat;
			}
		}
    },
	computed: {
		statTitle() {
			// if (this.stat.name === 'eggk') {
			// 	return 'eggK-47';
			// }
			return this.loc[this.stat.name];
			// return this.stat.name;
		},
		statMonthly() {
			if (this.stat.current && this.stat.current.length !== undefined && this.stat.kdr === undefined) {
				this.currentCls = 'display-grid grid-column-2-eq';
			}
			return this.setupStat(this.stat.current);
		},
		statLifetime() {
			if (hasValue(this.stat.lifetime) && this.stat.lifetime.length !== undefined && this.stat.kdr === undefined) {
				this.lifetimeCls = 'display-grid grid-column-2-eq';
			}
			return this.setupStat(this.stat.lifetime);
		},
		statWrapper() {
			// return this.stat.lifetime.length !== undefined && this.stat.kdr === undefined ? 'stats-grid-other' : 'stats-grid';
			return 'stats-grid-other';
		},
	},
};
</script>
<script>
var STATSPOPUP = {
    template: '#stats-stats-template',
    props: ['loc', 'statsMonthly', 'statsLifetime', 'kdrLifetime', 'showLifetime', 'eggsSpent', 'eggsSpentMonthly', 'challengesClaimed'],
	components: {
		'stat-item': StatTemplate
	},
    methods: {
		statName(key) {
			if (key === 'eggk') {
				key = 'eggK-47';
			}
			return key.toUpperCase();
		},
		kdr(kills, deaths) {
			return Math.floor((kills / Math.max(deaths, 1)) * 100) / 100;
		}
    },
	computed: {
		// VUE is taking it's time passing these props, so we need to wait for them to be ready
		renderReady() {
			return Object.keys(this.statsLifetime).length > 0 && Object.keys(this.statsMonthly).length > 0;
		}
	}
};
</script>
<script>
const ProfileScreen = {
	template: '#profile-screen-template',
	components: {
		'stats-content': STATSPOPUP,
		// 'player-name': PlayerNameInput
	},

	props: ['claimed'],

	data: function () {
		return vueData;
	},

	methods: {
		showSignIn: function () {
			extern.showSignInDialog();
			vueApp.$refs.firebaseSignInPopup.show();
		},
		onAccountBtnClicked: function () {
			if (this.showAdBlockerVideoAd) {
				return;
			}

			if (extern.inGame) {
				vueApp.onShowloginPopupWarning();
			} else {
				if (this.isAnonymous && this.showSignIn) {
				vueApp.onSignInClicked();
				} else {
					vueApp.onSignOutClicked();
				}
			}
		},

		onQuitAndLoginManage() {
			vueApp.onLeaveGameConfirm();
			setTimeout(() => {
				this.$emit('leave-game-confimed');
			}, 1000);
		},

		onTwitchDropsClick() {
			if (this.showAdBlockerVideoAd) {
				return;
			}

			ga('send', 'event', 'profilePage', 'click', 'twitch_drops');
			window.open(dynamicContentPrefix + 'twitch');
		},
		selectTab(val) {
			if (this.ui.profile.statTab === val) {
				return;
			}
			this.ui.profile.statTabClicked = true;
			setTimeout(() => this.ui.profile.statTabClicked = false, 500);
			BAWK.play('ui_toggletab');
			this.ui.profile.statTab = val;
		}
	},
	computed: {
		isEggStoreSaleItem() {
            return this.eggStoreItems.some( item => item['salePrice'] !== '');
        },
		showTwitchEvent() {
			return this.ui.events.twitch;
		},
		isTwitchLinked() {
			return this.twitchLinked ? this.loc.account_linked_to_twitch : this.loc.account_link_to_twitch;
		},
		accountStatus() {
			if (this.accountCreated) {
				return `${this.loc.account_created}: <strong>${this.accountCreated}</strong>`;	
			}
			return this.loc.account_profile_login_desc;
		},
		accountBtnCls() {
			if (this.isAnonymous && this.showSignIn) {
				return 'btn_green bevel_green';
			}
			return 'btn_yolk bevel_yolk';
			
		},
		accountBtnTxt() {
			if (this.isAnonymous && this.showSignIn) {
				return this.loc.sign_in;
			}
			return this.loc.sign_out;
		},
	}
};
</script><script id="gauge-template" type="text/x-template">
	<div id="ss-shell-meter-wrap">
		{{popupOpen}}
		<div id="gauge-meter" class="gauge-meter centered_x" @click="onGaugeMeterClick">
				<div class="hvsm-character-area hvsm-heroes-area-glow box_absolute" :style="heroesStyle">
				</div>
				<div class="hvsm-character-area hvsm-monsters-area-glow box_absolute" :style="monstersStyle">
				</div>
			<!-- <div id="motion-demo"></div> -->
			<div class="ss-shell-meter centered_x">
				<!-- ss-shell-gauge-->
				<div id="ss-shell-gauge" class="gauge">
					<img src="img/gauge-bar/hero-vs-monster-bar.webp" class="centered_x">
					<div ref="needle" class="needle">
						<!-- <div class="needle-head"></div> -->
						<img src="img/gauge-bar/hero-vs-monster-pointer.svg" class="centered_x">
					</div>
					<!-- .needle -->
				</div>
				<!-- #ss-shell-gauge -->
			</div>
			<!-- .ss-shell-meter -->
		</div>
	</div>
</script>

<script>
var CompGauge = {
	template: '#gauge-template',
	props: ['popupOpen'],
	data() {
		return {
			current: 180,
			min: 164,
			max: 196,
			loadvalue: null,
			setValue: 180,
			stop: false,
			started: false,
			rotateAnimation: 'hvsm-animation',
			pauseAnimation: 'hvsm-paused',
			stopCount: 0,
		};
	},

	methods: {
		setGaugeMeterData(data) {
			this.min = Number(data.min);
			this.max = Number(data.max);
			this.loadvalue = Number(data.loadvalue);
			this.stop = data.active;
			this.setValue = Number(data.setValue);
		},
		startMeter() {
			this.current = this.loadvalue;
			this.$refs.needle.addEventListener('animationend', () => this.restartAnimation());
			this.startAnimation();
		},
		getRandomInt(min, max) {
			min = Math.ceil(min);
			max = Math.floor(max);
			return Math.floor(Math.random() * (max - min + 1)) + min;
		},
		startAnimation() {
			const NeedleCls = this.$refs.needle.classList,
				  Current = this.current,
				  End = Math.round(this.getRandomInt(this.min, this.max)),
				  StepTime = ((Math.max(End, this.current) - Math.min(End,this.current)) * 1000),
				  Timer = Math.min(StepTime, 7000);

			if (NeedleCls.contains(this.pauseAnimation)) this.$refs.needle.classList.remove(this.pauseAnimation);
			if (NeedleCls.contains(this.rotateAnimation)) this.$refs.needle.classList.remove(this.rotateAnimation);

			this.setAnimationTimer(Timer);
			this.setAnimationStart(this.current);

			if (this.stop) {
				this.current = this.setValue
				this.setGaugeValue(this.current);
			} else {
				this.setGaugeValue(End);
				this.current = End;
			}

			this.$refs.needle.classList.add(this.rotateAnimation);
		},
		restartAnimation() {
			this.$refs.needle.classList.remove(this.rotateAnimation);
			if (this.stopCount >= 1) {
				this.stopMeter();
				this.stopCount = 0;
			}
			if (this.stop) {
				this.startAnimation();
				this.stopCount++;
				return;
			}
			setTimeout(() => {
				this.startAnimation();
			}, 3500);
		},
		minMax(val) {
			return val <= this.min || val >= this.max;
		},
		stopMeter() {
			this.$refs.needle.classList.add(this.pauseAnimation);
			this.$refs.needle.removeEventListener('animationend', () => this.restartAnimation());
		},
		opacityChange() {
            if (this.current >= 180) {
				return .1;
            } else {
                return ((180 - this.current) / 180) * 10;
            }
		},
		opacityChangeMonster() {
			if (this.current <= 180) {
				return .1;
			} else {
				return ((180 - this.current) / 180) * -10;
			}
		},
		onGaugeMeterClick() {
			this.$emit('gauge-meter-click');
		},
		setAnimationTimer(val) {
			this.$refs.needle.style.setProperty('--gauge-timer-sec', val/1000+'s');
		},
		setAnimationStart(val) {
			this.$refs.needle.style.setProperty('--gauge-value-start', val+'deg');
		},
		setGaugeValue(val) {
			this.$refs.needle.style.setProperty('--gauge-value', val+'deg');
		},
	},
	computed: {
		monsters() {
			return this.opacityChangeMonster()
		},
		heroes(){
			return this.opacityChange()
		},
		heroesStyle() {
			return {
				opacity: this.heroes,
			};
		},
		monstersStyle() {
			return {
				opacity: this.monsters,
			};
		},
		isPopupOpen() {
			return this.popupOpen ? 'hvsm-popup-open' : '';
		},
	},
	watch: {
		loadvalue(val) {
			if (val && !this.started) this.startMeter();
		},
	},
};
</script>
<script>
var comp_home_screen = {
	template: '#home-screen-template',
	components: {
		'play-panel': comp_play_panel,
		'house-ad-big': comp_house_ad_big,
		'house-ad-small': comp_house_ad_small,
		'account-panel': comp_account_panel,
		'chicken-panel': comp_chicken_panel,
		'footer-links-panel': comp_footer_links_panel,
		'event-panel': comp_events,
		'media-tabs': MEDIATABS,
		'profile-screen': ProfileScreen,
		'gauge-meter': CompGauge,
		'item': comp_item,
		// 'pwa-button': comp_pwa_btn,
	},

	data: function () {
		return vueData;
	},

	methods: {
		onHvsmPopupOpen() {
			this.getHvsmItems();
		},
		onHvsmPopupClose() {
		},
		onHvsmClicked(item) {
			let tag;	
			if (typeof item === 'object') {
				tag = item.item_data.tags.includes('Monsters') ? 'Monsters' : 'Heroes';
			} else {
				tag = item;
			}
			vueApp.showTaggedItemsOnEquipScreen(tag);
			// this.$refs.hvsmPopup.close();
		},
		playSound (sound) {
			BAWK.play(sound);
		},
		onEquipClicked: function () {
			if (this.showAdBlockerVideoAd) {
				return;
			}
			vueApp.openEquipSwitchTo();
			BAWK.play('ui_equip');
		},
		showSignIn: function () {
			extern.showSignInDialog();
			vueApp.$refs.firebaseSignInPopup.show();
		},
		onSignInClicked: function () {
			if (this.showAdBlockerVideoAd) {
				return;
			}
			this.showSignIn();
		},
		onSignOutClicked: function () {
			if (this.showAdBlockerVideoAd) {
				return;
			}
			extern.signOut();
		},
		leaveGameConfirmed() {
			if (this.showAdBlockerVideoAd) {
				return;
			}

			if (this.isAnonymous && this.showSignIn) {
				this.onSignInClicked();
			} else {
				extern.signOut();
			}
		},
		onResendEmailClicked: function () {
			extern.sendFirebaseVerificationEmail();
			// vueApp.showGenericPopup('verify_email_sent', 'verify_email_instr', 'ok');
			this.$refs.resendEmailConfirm.show();
		},
		onHideResendEmail() {
			extern.accountCreationNotification();
			// setTimeout(()=> vueApp.setDarkOverlay(true), 100);
		},
		onBigHouseAdClosed: function () {
			console.log('big house ad closed event received');
			this.ui.houseAds.big = null;
			this.urlParamSet = this.urlParams ? true : null;
			vueApp.showTitleScreenAd();
            vueApp.shellShockUrlParamaterEvents();
		},
		onPlayerNameChanged: function (newName) {
			console.log('play name event handler');
			vueApp.setPlayerName(newName);
			BAWK.play('ui_onchange');
		},
		onEggPlayClick() {
            play: 'play game',
			ga('send', 'event', vueData.googleAnalytics.cat.play, vueData.googleAnalytics.action.eggDollClick);
			vueApp.$refs.homeScreen.$refs.playPanel.onPlayButtonClick();
		},
		api_incentivizedVideoRewardRequest() {
			extern.api_incentivizedVideoRewardRequested();
		},
		onTwitchDropsClick() {
			if (this.showAdBlockerVideoAd) {
				return;
			}
			window.open(dynamicContentPrefix + 'twitch');
		},
		chwStopCycle() {
			if (this.chwHomeTimer) {
				clearInterval(this.chwHomeTimer);
				this.chwHomeTimer = '';
				this.chwHomeEl.classList.remove('.active');
			}
		},
		onGameTypeChanged(val) {
			vueApp.onGameTypeChanged(val);
		},
		// onGaugeMeterClick() {
		// 	this.$refs.hvsmPopup.show();
		// },

		getHvsmItems() {
			this.hvsm.hero.items = extern.getTaggedItems(this.hvsm.hero.name).filter( item => item.is_available);
			this.hvsm.monster.items = extern.getTaggedItems(this.hvsm.monster.name).filter( item => item.is_available);
		},
	
		challengeReroll(id) {
			// TODO: update challenge slot and add to player Account functionality
			// Add to limiter if reroll is consistently requested
			extern.playerChallenges.reroll(id);
		},
	},
	computed: {
		isEggStoreSaleItem() {
            return this.eggStoreItems.some( item => item['salePrice'] !== '');
        },
		twitchDropsBtnImgSrs() {
			if (this.twitchLinked) {
				return '../img/events/twitch-drops-btn-linked.webp';
			}
			return '../img/events/twitch-drops-btn-link-now.webp';
		},
		isTwitchLinked() {
			if (this.twitchLinked) return '<i class="fas fa-check-circle text_twitch_yellow"></i>';
			return '<i class="fas fa-times-circle text_grey"></i>';
		}
	}
};
</script><script id="gold-chicken-template" type="text/x-template">
    <div>
		<img v-lazyload :data-src="ui.lazyImages.chwPopup" class="lazy-load chw-popup-img" alt="Play chicken winner!">
		<h2 class="centered_x bottom-2 text_vip_yellow chw-popup-title fullwidth text-center">{{ loc.chw_popup_play }}</h2>
		<div id="btn_horizontal" class="centered_x bottom-2">
			<button @click="onCloseClick()" class="ss_button btn_red bevel_red">{{ loc.no_thanks }}</button>
            <button class="ss_button btn_green bevel_green" @click="onChickenClick">{{ loc.play_now }}</button>
    	</div>
    </div>
</script>

<script>
var comp_gold_chicken_popup = {
    template: '#gold-chicken-template',
	data: function () {
		return vueData;
    },
    props: [],
    methods: {
		onCloseClick: function () {
			this.$emit('close-chw-popup');
		},
		onChickenClick: function () {
			this.$emit('open-chw-game');
		}
    }
};
</script><script id="equip-screen-template" type="text/x-template">
	<div id="#equip_wrapper" :class="screenCls" data-html2canvas-ignore>
		<div id="display-ad-header-equip" ref="displayAdHeader"></div>
		<div class="home-main-wrapper display-grid box_absolute height-100vh">
			<section id="equip_panel_middle" class="equip_panel middle_panel box_relative align-items-center">
				<div v-if="showShopUi" class="panel_tabs display-grid grid-column-3-eq gap-sm">
					<button class="ss_bigtab bevel_blue roundme_md font-sigmar equip-tab-shop" :class="getButtonToggleClass(equipMode.shop)" @click="switchTo(equipMode.shop)">{{ loc.eq_shop }}</button>
					<button class="ss_bigtab bevel_blue roundme_md font-sigmar equip-tab-featured" :disabled="!accountSettled" :class="getButtonToggleClass(equipMode.featured)" @click="switchTo(equipMode.featured)">{{ loc.eq_featured }}</i></button>
					<button class="ss_bigtab bevel_blue roundme_md font-sigmar equip-tab-skins" :disabled="!accountSettled" :class="getButtonToggleClass(equipMode.skins)" @click="switchTo(equipMode.skins)">{{ loc.eq_skins }}</i></button>
				</div>
				<div v-show="isOnShopInventoryLimited" id="equip_purchase_top" class="equip_purchase_top">
					<physical-tag id="physical-tag" class="ss_marginright" v-if="equip.physicalUnlockPopup.item" ref="physical-tag" :loc="loc" :item="equip.physicalUnlockPopup.item" @buy-item-clicked="onBuyItemClicked"></physical-tag>
				</div>

				<div v-if="isSubscriber" v-show="equip.selectedItemType == 2" id="stamp-controls">
					<div class="row">
						<button class="button" @click="moveStampClick(0, 1)">
							<svg class="arrow up">
								<use xlink:href="#ico_stampArrow"></use>
							</svg>
						</button>
					</div>
					<div class="row">
						<button class="button" @click="moveStampClick(-1, 0)">
							<svg class="arrow left">
								<use xlink:href="#ico_stampArrow"></use>
							</svg>
						</button>
						<div class="preview" @click="resetStampPosition()">
							<canvas class="canvas" ref="stampCanvas" width="250" height="250"></canvas>
						</div>
						<button class="button" @click="moveStampClick(1, 0)">
							<svg class="arrow right">
								<use xlink:href="#ico_stampArrow"></use>
							</svg>
						</button>
					</div>
					<div class="row">
						<button class="button" @click="moveStampClick(0, -1)">
							<svg class="arrow down">
								<use xlink:href="#ico_stampArrow"></use>
							</svg>
						</button>
					</div>
				</div>

				<div v-show="isEquipModeInventory || isOnEquipModeSkins" id="equip_weapon_panel">
					<weapon-select-panel id="weapon_select" ref="weapon_select" :loc="loc" :account-settled="accountSettled" :play-clicked="playClicked" :current-class="classIdx" :current-screen="showScreen" :screens="screens" :hide-desc="!ui.showHomeEquipUi" @changed-class="onChangedClass"></weapon-select-panel>
				</div>
				<color-select v-if="isEquipModeInventory || isOnEquipModeSkins" id="equip.equipped_slots" ref="colorSelect" :loc="loc" :is-upgrade="isUpgraded" :color-idx="equip.colorIdx" :extra-colors-locked="equip.extraColorsLocked" @color-changed="onColorChanged" :current-screen="showScreen" :screens="screens"></color-select>
				<div id="limited-un-vaulted" v-show="isOnEquipModeFeatured || isEquipModeShop" class="limited-un-vaulted centered_x bottom-1 bg_blue2 roundme_lg paddings_lg">
					<item-grid id="item_grid" ref="itemGridVaulted" :loc="loc" :items="equip.showUnVaultedItems" :has-buy-btn="false" :selectedItem="equip.selectedItem" @item-selected="onItemSelected" :in-shop="isInShop" :in-inventory="showShopCart"></item-grid>
					<h4 class="text-center text-uppercase nospace text_blue5">{{ loc.eq_unvaulted_limited_msg }}</h4>
					<div class="price-tag-wrap">
						<price-tag id="price_tag" v-if="equip.selectedItem && isSelectedInUnVaulted" ref="price_tag" :loc="loc" :item="equip.selectedItem" :hide-get-more-eggs="true" :egg-total="eggs" @buy-item-clicked="onBuyItemClicked" :chw-ready="chw.ready"></price-tag>
					</div>
				</div>
			</section>
			<!-- end .middle_panel -->
			<section id="equip_panel_right" class="equip_panel right_panel">
				<h3 v-if="!showPurchasesUi" class="equip-title text-center margins_sm box_relative text_white text-shadow-black-40 nospace">{{ loc[equip.categoryLocKey] }}</h3>
				<div v-if="isOnEquipModeFeatured" class="limited-msg-wrapper box_relative display-grid align-items-center text-center text_vip_yellow bg-limited roundme_md">
					<p class="nospace">{{ loc.eq_limited_msg }}</p>
				</div>
				<item-type-selector v-if="isOnShopInventory" class="box_relative" id="item_type_selector" ref="item_type_selector" :items="ui.typeSelectors" :in-limited="isOnEquipModeFeatured" :selected-item-type="equip.selectedItemType" :show-special-items="equip.showSpecialItems" :in-shop="isInShop" @item-type-changed="switchItemType"></item-type-selector>
				<egg-store v-if="isEquipModeShop" :loc="loc" :products="eggShopSortItems" :sale-event="isSale" @on-bundle-info-clicked="openProductBundlePopup" @on-try-prem-item-on="equipTryPremItemOn"></egg-store>
				<div v-show="!isEquipModeShop" id="item-search-wrap" class="item-search-wrap box_relative">
					<label for="item-search" class="centered_y item-search-label"><i class="fas fa-search text_blue3" :class="[equip.itemSearchTerm ? 'fa-times-circle text_red' : 'fa-search']" @click="onItemSearchReset"></i></label>
					<input ref="itemSearch" name="item-search" v-bind:placeholder="loc.eq_search_items" v-on:keyup="onItemSearchChange" class="ss_field font-nunito box_relative fullwidth">
					<!-- <input ref="itemSearch" name="item-search" v-bind:placeholder="loc.eq_search_items" v-model="itemSearchVal" v-on:keyup="onItemSearchChange" class="ss_field font-nunito box_relative fullwidth"> -->
				</div>
				<div v-if="currentEquipMode !== equipMode.shop" id="equip_sidebox" class="equip-main-item-grid roundme_md box_relative ss_marginbottom_lg">
					<div v-show="ui.showHomeEquipUi" id="item_mask"></div>
					<div id="item-smack-down">
						<item-grid v-if="isOnShopInventoryLimited" id="item_grid" ref="item_grid" :loc="loc" :class="gridCls" :items="equip.showingItems" :selectedItem="equip.selectedItem" :category-loc-key="equip.categoryLocKey" :in-shop="isInShop" :in-inventory="showShopCart" :is-searching="equip.itemSearchTerm" :show-tooltips="true" @item-selected="onItemSelected" @switch-to-skins="onSwitchToSkinsClicked"></item-grid>
					</div>
					<!--<house-ad-small id="banner-ad" v-show="!isInShop"></house-ad-small>-->
				</div>
				<div v-show="isEquipModeInventory" class="ss_paddingright">
					<button  class="ss_button btn_blue bevel_blue box_relative fullwidth text-uppercase" :class="{'visibility-hidden' : !ui.showHomeEquipUi}" @click="onRedeemClick">{{ loc.eq_redeem }}</button>
					<button class="ss_button box_relative fullwidth text-uppercase btn-open-photo-booth" :class="photoBoothBtnUi.cls" @click="onPhotoboothClick" :disabled="extern.inGame">{{ photoBoothBtnUi.txt }}</button>
				</div>
				<price-tag id="price_tag" v-if="showPriceTag" ref="price_tag" :loc="loc" :item="equip.buyingItem" :egg-total="eggs" @buy-item-clicked="onBuyItemClicked" :chw-ready="chw.ready" :chw-watch-count="chw.winnerCounter"></price-tag>
			</section>
			<!-- .right_panel-->
		</div>

		<!-- Popup: Buy Item -->
		<small-popup id="buyItemPopup" ref="buyItemPopup" @popup-confirm="onBuyItemConfirm" @popup-closed="onBuyItemClose" :hideCancel="abTestInventory.enabled" :hideClose="abTestInventory.enabled" :overlayClose="!abTestInventory.enabled">
			<template slot="header">{{ loc.p_buy_item_title }}</template>
			<template slot="content">
				<div>
					<canvas id="buyItemCanvas" ref="buyItemCanvas" width="250" height="250"></canvas>
				</div>
				<div class="f_row f_center">
					<img v-if="!isBuyingItemPrem" src="img/ico_goldenEgg.webp" class="egg_icon"/>
					<i v-else class="fas fa-dollar-sign"></i>
					<h1>{{ (equip.buyingItem) ? equip.buyingItem.price : '' }}</h1>
				</div>
			</template>
			<template slot="cancel">{{ loc.p_buy_item_cancel }}</template>
			<template slot="confirm">{{ loc.p_buy_item_confirm }}</template>
			<template slot="footer">
				<div v-if="equip.chwRewardBuyItem && !abTestInventory" class="fullwidth ss_margintop">
					<button class="ss_button btn_yolk bevel_yolk fullwidth" @click="chwWatchAd">{{ loc[chwButtonTxt] }} <icon v-show="chw.ready && chw.winnerCounter > 0" name="ico_watchAd" class="chw-icon-watch-ads"></icon></button>
				</div>
			</template>
		</small-popup>

		<!-- Popup: Redeem Code -->
		<small-popup id="redeemCodePopup" ref="redeemCodePopup" :popup-model="equip.redeemCodePopup" @popup-confirm="onRedeemCodeConfirm">
			<template slot="header">{{ loc.p_redeem_code_title }}</template>
			<template slot="content">
				<div class="error_text shadow_red" v-show="equip.redeemCodePopup.showInvalidCodeMsg">{{ loc.p_redeem_code_no_code }}</div>
				<p><input type="text" class="ss_field ss_margintop ss_marginbottom text-center width_lg" v-model="equip.redeemCodePopup.code" v-bind:placeholder="loc.p_redeem_code_enter"></p>
			</template>
			<template slot="cancel">{{ loc.cancel }}</template>
			<template slot="confirm">{{ loc.confirm }}</template>
		</small-popup>

		<!-- Popup: Physical Unlock -->
		<small-popup id="physicalUnlockPopup" ref="physicalUnlockPopup" :popup-model="equip.physicalUnlockPopup" @popup-confirm="onPhysicalUnlockConfirm">
			<template slot="header">{{ loc.p_physical_unlock_title }}</template>
			<template slot="content">
				<div v-if="(equip.physicalUnlockPopup.item !== null)">
					<div>
						<item :loc="loc" :item="equip.physicalUnlockPopup.item" :isSelected="false" :show-item-only="true"></item>
						<div class="f_row f_center">
							<img src="img/ico_goldenEgg.webp" class="egg_icon"/>
							<h1>{{ loc.p_buy_special_price }}</h1>
						</div>
					</div>
					<div class="popup_sm__item_desc">
						{{ loc[equip.physicalUnlockPopup.item.item_data.physicalUnlockLocKey] }}
					</div>
				</div>
			</template>
			<template slot="cancel">{{ loc.cancel }}</template>
			<template slot="confirm">{{ loc.confirm }}</template>
		</small-popup>

		<small-popup id="bundlePopup" ref="bundlePopup" @popup-close="onBundlePopupClose" @popup-confirm="onBundlePopupConfirm">
			<template slot="header">{{ loc[equip.bundle.name] }}</template>
			<template slot="content">
				<img v-if="equip.bundle.img" :src="equip.bundle.img" class="bundle-popup-img centered_y"/>
				<item-grid id="bundleGrid" ref="bundleGrid" :loc="loc" :items="equip.bundle.items" :has-buy-btn="false" :selectedItem="null" @item-selected="onItemSelected"  :in-inventory="false" :hide-price="true" :show-tooltips="true"></item-grid>
				<h2 v-if="!equip.bundle.owned" class="bundle-popup-price text_yellow"><sup>$</sup>{{ equip.bundle.price }} USD</h2>
				<p v-if="equip.bundle.owned">{{ loc.product_bundles_items_owned }}</p>
			</template>
			<template slot="cancel">{{ loc.cancel }}</template>
			<template slot="confirm">{{ bundlePopupConfirmTxt }}</template>
		</small-popup>

		<!-- <large-popup id="hvsmPopup" ref="hvsmPopup" @popup-closed="onHvsmPopupClose" @popup-opened="onHvsmPopupOpen" @popup-x="onHvsmPopupClose" :overlayType="ui.overlayType.none">
			<template slot="content">
				<div id="hvsm-popup-item-grid-wrap" v-show="isOnEquipModeFeatured || isEquipModeShop" class="hvsm-popup-item-grid-wrap paddings_lg display-grid  grid-auto-flow-column align-items-center justify-content-center">
					<div class="hvsm-popup-item-grid">
						<header>
							<img class="display-block center_h" src="img/gauge-bar/shell_E&E_good_popup.webp" alt="Heroes logo">
							<h4 class="text-center text-uppercase nospace text_blue5">Heroes</h4>
						</header>
						<item-grid id="hvsmHeroesItemGrid" ref="hvsmHeroesItemGrid" :loc="loc" :items="equip.hvsmHeroItems" :has-buy-btn="false" :selectedItem="equip.selectedItem" @item-selected="onItemSelected" :in-shop="isInShop" :in-inventory="isEquipModeInventory"></item-grid>
						<div class="price-tag-wrap">
							<price-tag id="price_tag" v-if="onHsvmItemSelected(equip.hvsmHeroItems)" ref="price_tag" :loc="loc" :item="equip.selectedItem" :hide-get-more-eggs="true" :egg-total="eggs" @buy-item-clicked="onBuyItemClicked"></price-tag>
						</div>
					</div>
					<div class="hvsm-popup-desc">
						<header>
							<h2 class="nospace text_white text-shadow-black-40 text-center">Egg Org & Eggventure</h2>	
						</header>
						<p class="text_blue5">
							You should never have opened that chest & rolled the ancient arcane dice within…
							Welcome brave Eggventurers, to a tale of mystery, magic, & mayhem!
						</p>
						<p class="text_blue5">
							Here on the Outer Reach, Heroes & Monsters clash in epic battles, & danger lurks in the forest. Will the mighty Warriors, skilled Sorcerers, & cunning Rogues defeat the Beholders, Owlbears and Gelatinous Mounds?!
						</p>
						<p class="text_blue5">
							Equip your skins of choice to choose your side. Each kill with the equipped Monsters or Heroes items will bring your side closer to victory! Who will win? You decide. Either way you need to survive to get out of here!
						</p>
						<p class="text_blue5">
							Grab your swords & prepare yourshellves, for the eggventure of a lifetime awaits!
						</p>
					</div>
					<div class="hvsm-popup-item-grid">
						<header>
							<img class="display-block center_h" src="img/gauge-bar/shell_E&E_evil_popup.webp" alt="Monsters logo">
							<h4 class="text-center text-uppercase nospace text_blue5">Monsters</h4>
						</header>
						<item-grid id="hvsmMonsterItemGrid" ref="hvsmMonsterItemGrid" :loc="loc" :items="equip.hvsmMonsterItems" :has-buy-btn="false" :selectedItem="equip.selectedItem" @item-selected="onItemSelected" :in-shop="isInShop" :in-inventory="isEquipModeInventory"></item-grid>
						<div class="price-tag-wrap">
							<price-tag id="price_tag" v-if="onHsvmItemSelected(equip.hvsmHeroItems)" ref="price_tag" :loc="loc" :item="equip.selectedItem" :hide-get-more-eggs="true" :egg-total="eggs" @buy-item-clicked="onBuyItemClicked"></price-tag>
						</div>
					</div>
				</div>
			</template>
		</large-popup> -->
	</div>
</script>

<script id="equipped-slots-template" type="text/x-template">
	<div>
		<h3 class="margins_sm">{{ loc.eq_equipped }}</h3>
		<div id="equip_equippedslots">
			<div class="equip_item roundme_lg clickme f_row f_center" @click="onClick(itemType.Primary)">
				<item :loc="loc" id="primary_item" ref="primary_item" v-if="primaryItem" :item="primaryItem" class="equip_icon" :equippedSlot="true"></item>
				<div v-if="!primaryItem" class="equip_icon equip_icon_hat equip_icon_no_item"><img src="img/inventory-icons/ico_weaponPrimary.svg" alt="Primary equip slot"></div>
			</div>

			<div class="equip_item roundme_lg clickme f_row f_center" @click="onClick(itemType.Secondary)">
				<item :loc="loc" id="secondary_item" ref="secondary_item" v-if="secondaryItem" :item="secondaryItem" class="equip_icon" :equippedSlot="true"></item>
				<div v-if="!secondaryItem" class="equip_icon equip_icon_hat equip_icon_no_item"><img src="img/inventory-icons/ico_weaponSecondary.svg" alt="Secondary equip slot"></div>
			</div>

			<div class="equip_item roundme_lg clickme f_row f_center" @click="onClick(itemType.Grenade)">
				<item :loc="loc" id="grenade_item" ref="grenade_item" v-if="grenadeItem" :item="grenadeItem" class="equip_icon" :equippedSlot="true"></item>
				<div v-if="!grenadeItem" class="equip_icon equip_icon_hat equip_icon_no_item"><img src="img/inventory-icons/ico_grenade.svg" alt="Grenade equip slot"></div>

			</div>
			
			<div class="equip_item roundme_lg clickme f_row f_center" @click="onClick(itemType.Hat)">
				<item :loc="loc" id="hat_item" ref="hat_item" v-if="hatItem" :item="hatItem" :equippedSlot="true"></item>
				<div v-if="!hatItem" class="equip_icon equip_icon_hat equip_icon_no_item"><img src="img/inventory-icons/ico_hat.svg" alt="Hat item slot"></div>
			</div>
			
			<div class="equip_item roundme_lg clickme f_row f_center" @click="onClick(itemType.Stamp)">
				<item :loc="loc" id="stamp_item" ref="stamp_item" v-if="stampItem" :item="stampItem" :equippedSlot="true"></item>
				<div v-if="!stampItem" class="equip_icon equip_icon_stamp equip_icon_no_item"><img src="img/inventory-icons/ico_stamp.svg" alt="Stamp item slot"></div>
			</div>
		</div>
	</div>
</script>

<script>
var comp_equipped_slots = {
	template: '#equipped-slots-template',
	components: { 'item': comp_item },
	props: ['loc', 'primaryItem', 'secondaryItem', 'hatItem', 'stampItem', 'grenadeItem'],

	data: function () {
		return {
			itemType: ItemType
		}
	},

	methods: {
		onClick: function (itemType) {
			this.$emit('equipped-type-selected', itemType);
		}
	},

	computed: {
		emptyHatClass: function () {
			return (this.hatItem === null) ? 'equip_icon_hat' : '';
		},

		emptyStampClass: function () {
			return (this.stampItem === null) ? 'equip_icon_stamp' : '';
		}
	}
};
</script><script id="color-select-template" type="text/x-template">
	<div class="text-center egg-color-select roundme_sm common-box-shadow">
		<!-- <h3 class="margins_sm">{{ loc.eq_color }}</h3> -->
		<div id="equip_free_colors" class="display-grid text-center grid-auto-flow-column align-items-center ">
			<!-- <svg v-for="(c, index) in freeColors" class="eggIcon equip_color" :style="{ color: c }" :class="isSelectedClass(index)" @click="onClick(index)"><use xlink:href="#icon-egg"></use></svg> -->
			<span v-for="(c, index) in freeColors" class="box_relative roundme_sm egg-color-icon " @click="onClick(index)">
				<img v-if="index === colorIdx" class="centered_x color-select-arrow" src="img/svg/ico-arrow-colorPicker.svg"/>
				<i  class="fas fa-egg" :style="{ color: c }" :class="isSelectedClass(index)"></i>
			</span>
		<!-- </div>
		<div id="equip_paid_colors" class="display-grid text-center grid-auto-flow-column align-items-center "> -->

			<!-- <svg v-for="(c, index) in paidColors" class="eggIcon equip_color" :style="{ color: c }" :class="isSelectedClass(index + freeColors.length)" @click="onClick(index + freeColors.length)"><use :xlink:href="getExtraColorEggIcon"></use></svg> -->
			<span v-for="(c, index) in paidColors" class="box_relative roundme_sm egg-color-icon" @click="onClick(index + freeColors.length)">
				<img v-if="colorIdx === (index + freeColors.length)" class="centered_x color-select-arrow" src="img/svg/ico-arrow-colorPicker.svg"/>
				<span class="fa-stack roundme_sm" :class="isSelectedClass(index + freeColors.length)">
					<i class="fas fa-egg fa-stack-1x" :style="{ color: c }"></i>
					<i v-if="!isUpgrade" class="fas fa-lock fa-stack-1x text_white"></i>
				</span>
			</span>
		</div>
	</div>
</script>

<script>
var comp_color_select = {
	template: '#color-select-template',
	props: ['loc', 'colorIdx', 'extraColorsLocked', 'isUpgrade'],
	
	data: function () {
		return {
			freeColors: freeColors,
			paidColors: paidColors
		}
	},

	methods: {
		isSelectedClass: function (idx) {
			return (idx === this.colorIdx) ? 'selected' : ''
		},

		onClick: function (idx) {
			if (idx >= freeColors.length && this.extraColorsLocked === true) {
				vueApp.showSubStorePopup();
				// BAWK.play('ui_chicken');
				return;
			}

			this.$emit('color-changed', idx);
		},
	},

	computed: {
		getExtraColorEggIcon() {
			return (this.extraColorsLocked === true && !this.isUpgrade) ? '#icon-egg-locked' : '#icon-egg';
		},
	}
};
</script><script id="item-timer-template" type="text/x-template">
	<div>
		<div id="equip_timerem" class="box_blue3 roundme_sm shadow_blue4">
			<i class="fas fa-hourglass-start"></i> 9{{ loc.eq_day }}<span class="blink">:</span>12{{ loc.eq_hour }}
			<br>{{ loc.eq_remaining }}
		</div>
	</div>
</script>

<script>
var comp_item_timer = {
	template: '#item-timer-template',
	props: ['loc']
};
</script><script id="price-tag-template" type="text/x-template">
	<div id="equip_purchase_items" v-if="isNoPrice" class="equip_purchase_items box_relative">

		<button v-if="!playerNeedsMoreEggs && !isItemOwned" class="ss_button btn_green bevel_green btn_md btn_buy_item display-grid fullwidth font-nunito f_row align-items-center justify-content-center box_relative" @click="onBuyClick">
			{{priceTagText}}
			<img v-if="!isPremium" src="img/ico_goldenEgg.webp" class="ss_marginright_sm ss_marginleft">
			<i v-else class="fas fa-dollar-sign ss_marginleft"></i>
			{{ item.price }}
		</button>

		<button v-show="playerNeedsMoreEggs && !isItemOwned" class="ss_button btn_yolk bevel_yolk text-shadow-black-40 fullwidth text-center" @click="onWatchAdsClick">{{ watchAdsTxt }}! <icon v-show="showChwVideoIcon" name="ico_watchAd" class="chw-icon-watch-ads"></icon></button>
		<button v-show="!hideGetMoreEggs && !isItemOwned" class="ss_button btn_blue bevel_blue text-shadow-black-40 fullwidth text-center" @click="onGetMoreEggsClick">{{ loc.account_title_eggshop }}</button>
	</div>
</script>

<script>
var comp_price_tag = {
	template: '#price-tag-template',
	props: ['loc', 'item', 'eggTotal', 'chwReady', 'hideGetMoreEggs', 'chwWatchCount'],
	data() {
		return {
		};
	},

	methods: {
		onBuyClick: function () {
			if (this.isPremium) {
				return extern.buyProductForMoney(this.item.sku[0]);
			}
			this.$emit('buy-item-clicked', this.item);
		},
		onWatchAdsClick() {
			if (this.chwReady) ga('send', 'event', 'Chickn Winner', `btnClick${extern.inGame ? 'InGame' : 'Home'}`, 'watchToWinEggs');
			vueApp.showNuggyPopup();
		},
		onGetMoreEggsClick() {
			vueApp.openEquipSwitchTo(vueApp.equipMode.shop)
		}
	},
	computed: {
		isPremium() {
			return this.item.unlock === 'premium';
		},
		isNoPrice() {
			return this.item.price < 1000000000;
		},
		playerNeedsMoreEggs() {
			if (this.isPremium) {
				return false;
			} else {
				return this.item.price > this.eggTotal;
			}
		},
		priceTagText() {
			if (!this.playerNeedsMoreEggs) {
				return this.loc.eq_buy;
			}
			return;
		},
		priceTagTextCls() {
			if (!this.playerNeedsMoreEggs) {
				return 'text_blue5';
			} else {
				return 'text_red';
			}
		},
		watchAdsTxt() {
			if (this.chwReady) {
				return this.loc.chw_btn_watch_ad;
			} else {
				return 'Wait for more eggs';
			}
		},
		isItemOwned() {
			return extern.isItemOwned(this.item)
		},
		showChwVideoIcon() {
			return this.chwReady && this.chwWatchCount > 0;
		}
	}
};
</script><script id="physical-tag-template" type="text/x-template">
	<div id="equip_get_physical_item" class="equip_purchase_items">
		<div id="equip_pricetag" class="equip_pricetag shadow_blue2">
			<img src="img/pricetag_left.webp">
			<div class="equip_pricetag__tag equip_pricetag__is_special_tag">
				<img src="img/ico_goldenEgg.webp" class="ss_marginright">{{ loc.p_buy_special_price }}
			</div>
			<img src="img/pricetag_right.webp">
		</div>
		<button class="ss_button btn_yolk bevel_yolk is_special_get_btn" @click="onBuyClick">{{ loc.p_chicken_goldbutton }}</button>
	</div>
</script>

<script>
var comp_physical_tag = {
	template: '#physical-tag-template',
	props: ['loc', 'item'],

	methods: {
		onBuyClick: function () {
			this.$emit('buy-item-clicked', this.item);
		}
	}
};
</script><script id="item-type-selector-template" type="text/x-template">
	<div class="ss_marginbottom_sm">
		<div id="equip_itemtype" class="equip_panelhead display-grid grid-auto-flow-column align-items-center f_space_between">
			<div v-for="item in items" class="ico_itemtype clickme roundme_lg f_row align-items-center" :class="[getSelected(item), getTabStyle(item)]" @click="onItemTypeClick(item.type)">
				<svg>
					<use :xlink:href="item.img"></use>
				</svg>
			</div>
		</div>
	</div>
</script>

<script>
var comp_item_type_selector = {
	template: '#item-type-selector-template',
	props: ['items', 'showSpecialItems', 'selectedItemType', 'inShop', 'inLimited'],

	data: function () {
		return {
			showingTagged: false,
			selected: null
		}
	},

	methods: {
		onItemTypeClick: function (itemType) {
			this.selected = itemType;
			this.$emit('item-type-changed', itemType);
		},
		getTabStyle(item) {
			return 'type-selector-' + getKeyByValue(ItemType, item.type).toLowerCase();
		},
		getSelected(item) {
			return item.type === this.selectedItemType ? 'selected' : '';
		}
	}
};
</script><script id="item-grid-template" type="text/x-template">
	<div>
		<div v-if="accountSettled" id="equip_grid" :class="gridCls" class="display-grid">
			<item v-for="i in itemsSorted" :loc="loc" :item="i" :key="i.id" :isSelected="isSelected(i)" :has-buy-btn="hasBuyBtn" @item-selected="onItemSelected" :is-shop="inShop" :hide-price="hidePrice" :show-tooltip="showTooltips"></item>
			<div v-show="inInventory && !isSearching" class="grid-item roundme_sm clickme morestuff box_relative common-box-shadow btn_green bevel_green f_row align-items-center justify-content-center" @click="onSwitchToSkinsClick">
				<icon class="fill-white shadow-filter" name="ico-nav-shop"></icon>
			</div>
			<div v-show="(inShop && !hiddenPremItemCheck) || !itemsSorted.length" class="grid-item roundme_lg box_absolute centered soldout text-center">
				<div class="soldout_head shadow_bluebig5" v-html="emptyGridMsg.title"></div>
				<div class="soldout_text shadow_bluebig5" v-html="emptyGridMsg.text"></div>
			</div>
		</div>
		<div id="items-account-not-loaded" v-show="!accountSettled" class="text-center">
			<h3>{{loc.signin_auth_title}}</h3>
			<p>{{loc.signin_auth_msg}}</p>
		</div>
	</div>
</script>

<script>
var comp_item_grid = {
	template: '#item-grid-template',
	components: { 'item': comp_item },
	props: ['items', 'selectedItem', 'gridClass', 'categoryLocKey', 'inShop', 'hasBuyBtn', 'inInventory', 'hidePrice', 'showTooltips', 'isSearching'],
	data() {
		return vueData;
	},

	methods: {
		onItemSelected: function (selectedItem) {
			this.$emit('item-selected', selectedItem);
		},

		isSelected: function (item) {
			if (!hasValue(this.selectedItem)) {
				return false;
			}

			return (this.selectedItem.id === item.id);
		},

		onSwitchToSkinsClick: function () {
			this.$emit('switch-to-skins');
			BAWK.play('ui_playconfirm');
		},

		isPremItemInStore() {
			let hasItem = false;
			for (let i = 0; i < this.items.length; i++) {
				const item = this.items[i];
					const isItem = vueApp.premiumShopItems.find(i => i.isActive && i.itemId.id === item.id);
					if (hasValue(isItem)) {
						hasItem = true;
						break;
					}
			}
			return hasItem;
		}
	},

	computed: {
		categoryName: function () {
			if (!hasValue(this.selectedItem)) {
				return null;
			}

			return this.loc['item_type_' + this.selectedItem.item_type_id];
		},

		hiddenPremItemCheck() {
			if (this.items.some(i => i.unlock === 'purchase') || this.items.length !== 0) return true;
			if (this.items.some(i => i.unlock === 'premium')) return this.isPremItemInStore();
			return false;
		},

		gridCls() {
			if (this.hasBuyBtn) {
				return 'grid-auto-flow-column gap-1';
			} else {
				return 'grid-column-3-eq align-content-start align-content-start gap-sm';
			}
		},
		itemsSorted() {
			const unlockPriority = ['premium', 'vip', 'physical', 'manual', 'default', 'purchase'];

			return this.items.sort((b, a) => {
				const aTags = Array.isArray(a.item_data.tags) ? a.item_data.tags : [];
				const bTags = Array.isArray(b.item_data.tags) ? b.item_data.tags : [];

				// Check for 'Premium' tag with 'purchase' unlock
				const aIsPremiumPurchase = aTags.includes('Premium') && a.unlock === 'purchase';
				const bIsPremiumPurchase = bTags.includes('Premium') && b.unlock === 'purchase';

				if (aIsPremiumPurchase && !bIsPremiumPurchase) return 1;
				if (!aIsPremiumPurchase && bIsPremiumPurchase) return -1;

				const aPriority = unlockPriority.indexOf(a.unlock);
				const bPriority = unlockPriority.indexOf(b.unlock);

				return bPriority - aPriority;
			});
		},
		emptyGridMsg() {
			if (this.isSearching) {
				return {
					title: this.loc['eq_search_out_head'],
					text: this.loc['eq_search_out_text']
				}
			} else {
				return {
					title: this.loc['eq_sold_out_head'],
					text: this.loc['eq_sold_out_text']
				}
			}

		}
	}
};
</script><script id="egg-store-template" type="text/x-template">
	<div class="f_col">
		<egg-store-item v-for="item in products" :key="item.sku" :item="item" :loc="loc" inStore="true" :account-set="accountSettled" :isUpgraded="isUpgraded" :isSaleEvent="saleEvent" @on-bundle-info-clicked="openProductBundlePopup" @on-try-prem-item-on="onTryPremItemOn"></egg-store-item>
	</div>
</script>

<template id="comp-store-item">
    <div v-if="showItem" class="single-egg-store-item box_relative align-items-center roundme_md common-box-shadow" :class="[itemCls, {purchased: purchased}]">
		<header v-if="productTypeItem || productTypeBundle" class="grid-span-2-start-1">
			<h6 class="single-egg-store-header nospace f_row align-items-center f_space_between">
				{{ loc[title] }}
				<icon v-if="productTypeItem" class="egg-store-item-type" :name="productIcon"></icon>
			</h6>
		</header>
		<div class="display-grid grid-column-1-2 align-items-center text-center">
			<div>
				<img :src="img" class="eggshop_image roundme_md display-block center_h" :class="imgCls" @click="onTryPremItemOn">
				<div v-if="productTypeItem" class="text-center">
					<div class="eggshop_pricebox text_brown" :class="{ slashed: item.salePrice }">
						${{ price }} <span>USD</span>
					</div>
				</div>
			</div>
			<div>
				<header v-if="!productTypeItem && !productTypeBundle">
					<h6 class="eggshop_bigtitle nospace text_blue5">{{ loc[title] }}</h6>
				</header>
				<div class="display-grid">
					<p v-if="showSubtitle" class="eggshop_subtitle font-sigmar" :class="subTitleCls" v-html="loc[description]"></p>
				</div>
				<div class="single-egg-store-price box_relative z-index-2">
					<p v-if="!productTypeItem" class="eggshop_pricebox nospace display-inline" :class="priceCls"><span class="eggshop-dollar-sign">$</span>{{ item.price }}<span class="eggshop-currency-type"> USD</span></p>
					<button v-if="productTypeBundle" class="btn_store ss_button btn_yolk bevel_yolk btn_sm" @click="onBundleInfoClicked">More info</button>
					<button class="btn_store ss_button btn_green bevel_green btn_sm" @click="onItemClicked()" :disabled="purchased && productTypeBundle">{{ buyBtnText }}</button>
				</div>
				<button v-if="productTypeItem && !purchased && inStore" class="ss_button btn_yolk bevel_yolk btn_sm center_h vip-get-btn f_row align-items-center" @click="onVipClick"><span v-html="loc.p_egg_shop_free_with_vip"></span><icon class="egg-store-item-type shadow-filter" name="ico-vip"></icon></button>

			</div>
		</div>
		<!-- <div v-if="item.salePrice" class="sale-desc box_absolute bottom-0">{{ loc.egg_pack_special_msg }}</div> -->
	</div>
</template>
<script>
    const comp_store_item = {
        template: '#comp-store-item',
        props: ['loc', 'item', 'inStore', 'accountSet', 'isUpgraded', 'isSaleEvent'],
        data() {
            return {
                purchased: false,
                attempt: 0,
				productItems: [],
				productIcon: '',
				bundleInfo: {
					items: [],
					isOwned: false,
					price: 0,
					img: '',
					name: '',
				},
            };
        },
		mounted() {
			this.setupProduct();
		},
        methods: {

			onTryPremItemOn() {
				if (this.productTypeItem) {
					this.$emit('on-try-prem-item-on', this.productItems[0]);
				}
			},

            onItemClicked() {
                if (!this.accountSet || !vueApp.accountSettled) {
                    vueApp.hideEggStorePopup();
                    setTimeout(() => {
                        if (this.attempt < 5) {
                            this.onItemClicked(this.item.sku);
                            this.attempt++;
                        } else {
                            vueApp.showGenericPopup('uh_oh', 'error', 'ok');
                        }
                    }, 300);
                    vueApp.pleaseWaitPopup();
                    return;
                }
				
				// vueApp.hidePopupEggStoreSingle();

				if ((this.item.type === 'item' || this.item.type === 'bundle') && !hasValue(this.item.itemIds[0])) {
					vueApp.showGenericPopup('uh_oh', 'p_egg_shop_no_item_id', 'ok');
					return;
				}

				if (this.purchased && this.productTypeItem) {
					console.log('Item is owned so lets go see it.');
					vueApp.showItemOnEquipScreen(extern.catalog.findItemById(this.item.itemIds[0]));
					return;
				}

                extern.buyProductForMoney(this.item.sku);

                ga('send', 'event', vueApp.googleAnalytics.cat.purchases, vueApp.googleAnalytics.action.eggShackProductClick, this.item.sku);
            },
			onBundleInfoClicked() {
				if (this.bundleInfo.items.length === 0) {
					this.productItems.forEach(item => {
						this.bundleInfo.items.push(item);
					});
					this.bundleInfo.isOwned = this.purchased;
					this.bundleInfo.price = this.price;
					this.bundleInfo.img = this.img;
					this.bundleInfo.name = this.description;
				}

				this.$emit('on-bundle-info-clicked', this.bundleInfo);
			},
            onVipClick() {
                // this.$parent.$parent.hide();
                vueApp.showSubStorePopup();
            },
			getItemType() {
				const item = extern.catalog.findItemById(this.item.itemIds[0]);
				const obj = {};

				if (item.exclusive_for_class !== null) {
					obj.name = getKeyByValue(CharClass, item.exclusive_for_class).toLowerCase();
					obj.isClass = true;
				} else {
					obj.name = getKeyByValue(ItemType, item.item_type_id).toLowerCase();
					obj.isClass = false;
				}

				return obj;
			},
			setupProduct() {
				switch (this.item.type) {
					case 'item':
						this.productItems = [extern.catalog.findItemById(this.item.itemIds[0])];
						this.purchased = extern.isItemOwned(this.productItems[0]);
						this.getIcon();
						break;
					case 'bundle':
						let owned = [];
						this.productItems = extern.catalog.findItemsByIds(this.item.itemIds);
						this.productItems.forEach(item => {
							if (extern.isItemOwned(item)) {
								owned.push(item.id)
							}
						});
						this.purchased = owned.length === this.productItems.length;
						break;
				
					default:
						break;
				}
			},
			getIcon() {
				if (this.productItems[0].exclusive_for_class !== null) {
					this.productIcon = `ico-weapon-${getKeyByValue(CharClass, this.productItems[0].exclusive_for_class).toLowerCase()}`;
				} else {
					this.productIcon = `ico-${getKeyByValue(ItemType, this.productItems[0].item_type_id).toLowerCase()}`;
				}
			}
        },
        computed: {
			productTypeItem() {
				return this.item.type === 'item'
			},
			productTypeBundle() {
				return this.item.type === 'bundle'
			},
			productTypeCurrency() {
				return this.item.type === 'currency'
			},
            title() {
				if (this.productTypeBundle) {
					return `product_bundles_title`;
				}
                return `${this.item.sku}_title`;
            },
			imgCls() {
				return this.productTypeBundle ? 'box_absolute egg-store-bundle-img centered_y z-index-1' : '';
			},
			priceCls() {
				return this.productTypeBundle ? 'text_yellow' : 'text_blue5';
			},
            description() {
				if (this.productTypeBundle) {
					return `${this.item.sku}_title`;
				}
                return `${this.item.sku}_desc`;
            },
			saleDesc() {
				if (this.item.salePrice) {
					return `${this.item.sku}_sale_desc`;
				}
			},
            img() {
				switch (this.item.type) {
					case 'item':
						return `img/store/items/${this.item.sku}.gif`;
						break;
					case 'bundle':
						return `img/store/bundles/${this.item.sku}.webp`;
						break;
					default:
					return `img/${!this.isSaleEvent ? '' : 'store-black-friday/'}${this.item.sku}.webp`;
						break;
				}
            },
            itemType() {
                return 'single-egg-store-item-is-' + this.item.type;
            },
			itemCls() {
				return `${this.itemType} ${this.item.sku} ${this.item.type === 'currency' ? '' : ''}`;
			},
            buyBtnText() {
                if (this.purchased && this.productTypeItem) {
                    return this.loc.p_egg_shop_see_item;
                } else if (this.productTypeBundle && this.purchased) {
					return this.loc.eq_owned;
				}
                return this.loc.p_buy_item_confirm;
            },
            showItem() {
                if (this.inStore) return this.item.inStore;
                return true;
            },
            flagTxt() {
                if (this.item.salePrice) {
                    return 'fa-tag';
                }
                return 'fa-gem'
            },
			showSubtitle() {
				if (this.productTypeItem) return true;
				if (this.isSaleEvent) {
					return false;
				}
				return true;
			},
			price() {
				if (this.item.salePrice) {
					return this.item.salePrice;
				} else {
					return this.item.price;
				}
			},
			subTitleCls() {
				switch (this.item.type) {
					case 'item':
						return 'text-center text_brown';
						break;
					case 'bundle':
						return 'text-shadow-black-40 text_white';
						break;
				
					default:
						return 'text_blue5 nospace';
						break;
				}
			},
        },
    };
</script>
<script>
var comp_egg_store = {
    template: '#egg-store-template',
    components: {
        'egg-store-item': comp_store_item,
    },
    data() {
        return vueData;
    },
    props: ['products', 'saleEvent'],
    
    methods: {
        onItemClicked: function (sku) {
            if (!this.accountSettled) {
                console.log(this.$parent.hide());
                setTimeout(() => {
                    this.onItemClicked(sku[0])
                }, 300);
                vueApp.pleaseWaitPopup();
                return;
            }
            if (vueApp.$refs.genericPopup.isShowing === true) vueApp.$refs.genericPopup.close();
            this.$parent.hide();
            extern.buyProductForMoney(sku[0]);
            ga('send', 'event', this.googleAnalytics.cat.purchases, this.googleAnalytics.action.eggShackProductClick, sku);
        },
		openProductBundlePopup(items) {
			this.$emit('on-bundle-info-clicked', items);
		},
		onTryPremItemOn(item) {
			this.$emit('on-try-prem-item-on', item);
		},
    },
};
</script>


<script>
var comp_equip_screen = {
	template: '#equip-screen-template',
	components: {
		'equipped-slots': comp_equipped_slots,
		'color-select': comp_color_select,
		'item-timer': comp_item_timer,
		'price-tag': comp_price_tag,
		'physical-tag': comp_physical_tag,
		'item-type-selector': comp_item_type_selector,
		'item-grid': comp_item_grid,
		'house-ad-small': comp_house_ad_small,
		'weapon-select-panel': comp_weapon_select_panel,
		'item': comp_item,
		// 'account-panel': comp_account_panel,
		'house-ad-small': comp_house_ad_small,
		'egg-store': comp_egg_store,
		'settings-control-binder': comp_settings_control_binder,
		'settings-gamepad-binder': comp_settings_gamepad_binder,
		'language-selector': comp_language_selector,
		'settings-adjuster': comp_settings_adjuster,
		'settings-toggler': comp_settings_toggler
	},

	created() {
		this.debouncedSearch = debounce((newValue, oldValue) => this.onItemSearch(newValue, oldValue), 500);
	},

	data: function () {
		return vueData;
	},

	equippedItems: {},

	methods: {

		onItemSearchChange() {
			this.itemSearchVal = this.$refs.itemSearch.value;
		},

		setupItemGridMain() {
			if (this.isOnEquipModeFeatured) {
				this.populateItemGridWithTagged(this.equip.specialItemsTag);
			} else {
				this.populateItemGridWithType(this.equip.selectedItemType);
			}
		},

		setup: function (itemType, wasFeatured) {
			if (!itemType) {
				itemType = ItemType.Primary;
			}

			this.updateEquippedItems();

			this.equip.posingStampPositionX = extern.account.stampPositionX || 0;
			this.equip.posingStampPositionY = extern.account.stampPositionY || 0;

			this.poseEquippedItems();

			if (itemType === 'tagged' || wasFeatured) {
				this.populateItemGridWithTagged(this.equip.specialItemsTag);
			} else {
				this.populateItemGridWithType(itemType);
			}

			this.selectEquippedItemForType();
		},

		itemAvailForPurchase(i) {
			return i.is_available && i.unlock === 'purchase';
		},

		onPopupOpened() {
			if (this.equip.selectedItemType == ItemType.Stamp)
			{
				this.removeKeyboardStampPositionHandlers();
			}
		},

		onPopupClosed() {
			if (this.equip.selectedItemType == ItemType.Stamp && this.currentEquipMode == this.equipMode.inventory)
			{
				this.addKeyboardStampPositionHandlers();
			}
		},

		onHvsmPopupOpen() {
			this.setup('tagged');
			this.equip.hvsmHeroItems = extern.getTaggedItems('premFeatOne').filter(i => this.itemAvailForPurchase(i));
			this.equip.hvsmMonsterItems = extern.getTaggedItems('premFeatOne').filter(i => this.itemAvailForPurchase(i));
		},
		onHvsmPopupClose() {
			vueApp.switchToHomeUi();
		},
		// onHsvmItemSelected(items) {
		// 	return this.equip.selectedItem !== undefined ? items.some(i => i.id === this.equip.selectedItem.id) : false;
		// },

		updateEquippedItems: function () {
			this.equipped = extern.getEquippedItems();
			this.equip.posingStampPositionX = extern.account.stampPositionX;
			this.equip.posingStampPositionY = extern.account.stampPositionY;
		},

		clamp: function(value, min, max) {
			return Math.min(Math.max(value, min), max);
		},

		moveStampClick: function(x, y) {
			BAWK.play('ui_onchange');
			this.moveStamp(x, y);
		},

		moveStamp: function(x, y) {
			if (this.isSubscriber) {
				x = this.clamp(this.equip.posingStampPositionX + x, -12, 12);
				y = this.clamp(this.equip.posingStampPositionY + y, -15, 17);
				this.equip.posingStampPositionX = x;
				this.equip.posingStampPositionY = y;
				if (this.currentEquipMode == this.equipMode.inventory) {
					extern.account.stampPositionX = x;
					extern.account.stampPositionY = y;
				}
				extern.setStampPosition(x, y);
			}
		},

		resetStampPosition: function() {
			BAWK.play('ui_onchange');

			this.equip.posingStampPositionX = 0;
			this.equip.posingStampPositionY = 0;
			extern.setStampPosition(0, 0);
		},

		poseEquippedItems: function () {
			let items = {
				[ItemType.Hat]: this.equipped[ItemType.Hat],
				[ItemType.Stamp]: this.equipped[ItemType.Stamp],
				[ItemType.Primary]: this.equipped[ItemType.Primary],
				[ItemType.Secondary]: this.equipped[ItemType.Secondary],
				[ItemType.Grenade]: this.equipped[ItemType.Grenade],
				[ItemType.Melee]: this.equipped[ItemType.Melee]
			}

			if (this.ui.showHomeEquipUi === false) {
				Object.keys(items).forEach(key => {
					key = parseInt(key, 10);
					if (key !== this.equip.selectedItemType) {
						delete items[key];
					}
				});
			} else {
				switch (this.equip.showingWeaponType) {
					case ItemType.Primary:
						items[ItemType.Melee] = null;
						items[ItemType.Grenade] = null;
						break;
					case ItemType.Secondary:
						items[ItemType.Melee] = null;
						items[ItemType.Grenade] = null;
						break;
					case ItemType.Melee:
						items[ItemType.Primary] = null;
						items[ItemType.Grenade] = null;
						break;
					case ItemType.Grenade:
						items[ItemType.Secondary] = null;
						items[ItemType.Melee] = null;
						break;
					default:
						items[ItemType.Melee] = null;
						items[ItemType.Grenade] = null;
						break;
				}
			}

			var stampPosX = this.equip.posingStampPositionX;
			var stampPosY = this.equip.posingStampPositionY;

			extern.poseWithItems(items, stampPosX, stampPosY);
		},

		selectEquippedItemForType: function () {
			this.equip.selectedItem = this.equipped[this.equip.selectedItemType];
		},

		populateItemGridWithType: function (itemType) {
			this.equip.selectedItemType = itemType;
			var items = extern.getItemsOfType(itemType);
			this.populateItemGrid(items);

			this.equip.categoryLocKey = 'item_type_{0}{1}'.format(itemType, ((itemType === ItemType.Primary) ? '_' + this.classIdx : ''));
		},

		populateItemGridWithTagged: function (tag, itemType) {
			tag = tag || 'tagged'; // sometimes its empty buy why would we want show an empty grid so lets default to the special tag
			var items = extern.getTaggedItems(tag, itemType);
			this.populateItemGrid(items);
			this.equip.categoryLocKey = 'item_type_5';
		},

		populateItemGrid: function (items) {
			if (this.currentEquipMode === vueData.equipMode.inventory) {
				items = items.filter(i => extern.isItemOwned(i) || (i.is_available && i.unlock === "default"));
			} else {
				items = items.filter(i => i.is_available && !extern.isItemOwned(i) && (i.unlock === 'purchase' || (i.unlock === 'premium' && i.sku && i.activeProduct)));
			}

			this.equip.showingItems = items;
		},

		onBackClick: function () {
			vueApp.showSpinner();

			if (!this.isInShop) {
				extern.account.stampPositionX = this.equip.posingStampPositionX;
				extern.account.stampPositionY = this.equip.posingStampPositionY;
			}

			extern.saveEquipment(() => {
				if (extern.inGame) {
					// vueApp.showRespawnDisplayAd();
					extern.closeEquipInGame();
				}
				vueApp.hideSpinner();
				this.equip.showingWeaponType = ItemType.Primary;
			});
		},

		stampPositionKeyboardHandler(e) {
			var keybinds = this.settingsUi.controls.keyboard.game;
			if (e.key.toUpperCase() == keybinds[keybinds.findIndex(item => item.id === "up")].value) {
				this.moveStamp(0, 1);
			} else if (e.key.toUpperCase() == keybinds[keybinds.findIndex(item => item.id === "down")].value) {
				this.moveStamp(0, -1);
			} else if (e.key.toUpperCase() == keybinds[keybinds.findIndex(item => item.id === "left")].value) {
				this.moveStamp(-1, 0);
			} else if (e.key.toUpperCase() == keybinds[keybinds.findIndex(item => item.id === "right")].value) {
				this.moveStamp(1, 0);
			}
		},

		addKeyboardStampPositionHandlers: function () {
			document.addEventListener("keydown", this.stampPositionKeyboardHandler, false);
		},

		removeKeyboardStampPositionHandlers: function () {
			document.removeEventListener("keydown", this.stampPositionKeyboardHandler);
		},

		switchItemType: function (itemType) {
			if (itemType !== this.equip.selectedItemType) {

				// skins should only show the selected primary/secondary weapon if it's on the primary/secondary tab
				if (this.currentEquipMode === this.equipMode.skins) {
					this.equipped[ItemType.Primary] = extern.account.getPrimaryWeapon();
					this.equipped[ItemType.Secondary] = extern.account.getSecondaryWeapon();
				}

				if (itemType === ItemType.Primary || itemType === ItemType.Secondary || itemType == ItemType.Grenade || itemType == ItemType.Melee) {
					this.equip.showingWeaponType = itemType;
				}
				else {
					this.equip.showingWeaponType = null;
				}

				this.equip.selectedItemType = itemType;

				if (!this.ui.showHomeEquipUi) this.$emit('photo-booth-type-id');

				this.poseEquippedItems();
				if (itemType === ItemType.Stamp && this.currentEquipMode == this.equipMode.inventory) {
					this.addKeyboardStampPositionHandlers();
					setTimeout(() => this.renderStamp(), 0);
				} else {
					this.removeKeyboardStampPositionHandlers();
				}
				this.populateItemGridWithType(itemType);

				if (this.equip.itemSearchTerm) {
					this.itemSearch();
				}

				if (this.isEquipModeInventory) {
					this.selectEquippedItemForType();
				} else {
					this.selectFirstItemInShop();
				}

			}
			if (!this.isInShop) {

				this.hideItemForSale();
				this.hideItemForSpecial();

			}

			BAWK.play('ui_click');
		},

		itemSearch() {
			const SearchItems = new Fuse(this.equip.showingItems, extern.fuseOptions).search(this.equip.itemSearchTerm);

			if (SearchItems.length > 0) {
				console.log('ItemSearch result start');
				console.log('ItemSearch Term', this.equip.itemSearchTerm);
				console.log('ItemSearch Items array');
				console.log('ItemSearch SearchItems', SearchItems);
				this.equip.showingItems.length = 0;
				SearchItems.forEach(i => {

					console.log('ItemSearch item: ', i.item.name, 'tags: ', i.item.hasOwnProperty('item_data') && i.item.item_data.hasOwnProperty('tags') ? JSON.stringify(i.item.item_data.tags) : '', 'meshName: ', i.item.hasOwnProperty('item_data') && i.item.item_data.hasOwnProperty('meshName') ? i.item.item_data.meshName : 'None, i am a stamp', 'unlock: ', i.item.unlock)
					this.equip.showingItems.push(i.item)
				});
				console.log('ItemSearch result end');

			} else {
				this.equip.showingItems.length = 0;
			}
		},

		onItemSearch(newVal, oldVal) {
			// reset the grid if the search term shortens so we search the full list again
			if (newVal !== oldVal) {
				this.setupItemGridMain();
			}

			if (newVal.length >= 1) {
				this.equip.itemSearchTerm = newVal.toLowerCase().replace(/\s/g, '');
				this.itemSearch();
			} else if (!newVal.length) {
				this.onItemSearchReset();
			}
		},

		onItemSearchReset() {
			this.itemSearchVal = '';
			this.equip.itemSearchTerm = '';
			this.$refs.itemSearch.value = '';
			this.setupItemGridMain();
		},

		onTaggedItemsClicked: function () {
			if (this.equip.selectedItemType === 'tagged') {
				return;
			}
			this.showTaggedItems(this.equip.specialItemsTag);
			this.selectFirstItemInShop();
		},

		onTaggedResetItems() {
			this.showTaggedItems(this.equip.specialItemsTag);
			this.selectFirstItemInShop();	
		},

		onPremiumItemsClicked() {
			if (this.equip.selectedItemType === 'premium') {
				return;
			}
			this.showPremiumItems();
			this.selectFirstItemInShop();
		},

		showPremiumItems() {
			this.equip.selectedItemType = 'premium';
			var items = extern.getPremiumItems();
			this.populateItemGrid(items);
			this.equip.categoryLocKey = 'item_type_7';
		},

		showTaggedItems: function (tag, itemType) {
			this.equip.selectedItemType = 'tagged';

			if ((this.isEquipModeInventory && !this.ownsTaggedItems(this.equip.specialItemsTag)) || extern.openShopOnly) {
				this.currentEquipMode = this.equipMode.shop;
				vueApp.conditionalAnonWarningCall();
				extern.openShopOnly = false;

			}

			this.populateItemGridWithTagged(tag);
		},

		showSelectedTagItems(tag) {
			this.equip.selectedItemType = 'tagged';
			// if (this.equip.mode === this.equip.equipMode.inventory) {
			// 	this.equip.mode = this.equip.equipMode.shop;
			// }
			this.populateItemGridWithTagged(tag);
		},

		ownsTaggedItems: function (tag) {
			return extern.getTaggedItems(tag).filter(i => {
					return extern.isItemOwned(i);
				}).length > 0;
		},

		selectFirstItemInShop: function () {
			if (this.isInShop && this.equip.showingItems.length > 0) {
				this.selectItem(this.equip.showingItems[0]);
			}
		},

		switchTo: function (mode, useItemType) {
			this.equip.showingItems = [];
			if (!useItemType) this.equip.showingWeaponType = ItemType.Primary;

			if (useItemType) this.switchItemType(useItemType);

			this.$refs.itemSearch.value = '';
			this.equip.itemSearchTerm = '';

			switch (mode) {
				case this.equipMode.shop:
					this.currentEquipMode = this.equipMode.shop;
					this.getVaultedItemsForGrid(true);
					this.updateEquippedItems();
					this.poseEquippedItems();
					this.removeKeyboardStampPositionHandlers();
					vueApp.conditionalAnonWarningCall();
					break;

				case this.equipMode.inventory:
					if (this.equip.selectedItemType === 'tagged' && this.isOnEquipModeSkins || this.equip.selectedItemType === 'tagged' && this.isOnEquipModeFeatured) {
						if (!this.ownsTaggedItems(this.equip.specialItemsTag)) {
							this.switchItemType(ItemType.Primary);
						}
					}
					this.currentEquipMode = this.equipMode.inventory;
					this.equip.stampPositionX = extern.account.stampPositionX;
					this.equip.stampPositionY = extern.account.stampPositionY;
					extern.setStampPosition(this.equip.stampPositionX, this.equip.stampPositionY);
					this.hideItemForSale();
					this.hideItemForSpecial();
					this.poseEquippedItems();
					this.showItemsAfterEquipModeSwitch();
					this.selectEquippedItemForType();
					if (this.equip.selectedItemType == ItemType.Stamp)
					{
						this.addKeyboardStampPositionHandlers();
					}
					break;

				case this.equipMode.featured:
					this.updateEquippedItems();
					this.poseEquippedItems();
					this.showTaggedItems(this.equip.specialItemsTag)
					this.onTaggedItemsClicked();
					this.getVaultedItemsForGrid(true);
					this.removeKeyboardStampPositionHandlers();
					this.currentEquipMode = this.equipMode.featured;
					vueApp.conditionalAnonWarningCall();
					break;

				case this.equipMode.skins:
					this.setup(useItemType);
					this.currentEquipMode = this.equipMode.skins;
					this.showItemsAfterEquipModeSwitch();
					this.removeKeyboardStampPositionHandlers();
					if (useItemType === ItemType.Stamp) {
						setTimeout(() => this.renderItem(), 0);
					}
					vueApp.conditionalAnonWarningCall();
					break;

				default:
					break;
			}

			// stop the ad from manually refreshing on every tab switch and inventory 

			if (this.equip.displayAdHeaderRefresh) {
				vueApp.showHeaderAd();
				this.equip.displayAdHeaderRefresh = false;
			}

			this.selectFirstItemInShop();

			BAWK.play('ui_toggletab');
			// vueApp.histPushState({game: this.screens.equip}, 'Shellshockers equipment shop', '?equip=shop');
		},

		showItemsAfterEquipModeSwitch: function () {
			if (this.equip.selectedItemType === 'tagged') {
				this.showTaggedItems(this.equip.specialItemsTag)
			} else if (this.equip.selectedItemType === 'premium') {
				this.showPremiumItems();
			} else {
				this.populateItemGridWithType(this.equip.selectedItemType);
			}
		},

		onEquippedTypeSelected: function (itemType) {
			this.equip.selectedItemType = itemType;
			if ([ItemType.Primary, ItemType.Secondary, ItemType.Grenade, ItemType.Melee].includes(this.equip.selectedItemType)) {
				this.equip.showingWeaponType = itemType;
			} else {
				this.equip.showingWeaponType = null;
			}
			this.switchTo(this.equipMode.inventory);
		},

		onChangedClass: function () {

			this.hideItemForSale();
			this.hideItemForSpecial();
			this.updateEquippedItems();

			if (this.equip.selectedItemType !== ItemType.Primary) {
				this.onEquippedTypeSelected(ItemType.Primary);
			}

			this.populateItemGridWithType(this.equip.selectedItemType);

			if (this.equip.itemSearchTerm) {
				this.itemSearch();
			}

			if (extern.inGame && this.showScreen !== this.screens.equip) {
				this.equip.showingWeaponType = ItemType.Primary;
				extern.closeEquipInGame(true);
			}
			if (!this.ui.showHomeEquipUi) this.$emit('photo-booth-type-id');
			this.poseEquippedItems();
		},

		autoSelectItem: function (item) {

			if (this.showScreen !== this.screens.equip) {
				this.showScreen = this.screens.equip;
			}

			if (extern.isItemOwned(item)) {
				this.switchTo(this.equipMode.inventory);
			} else {
				this.switchItemType(item.item_type_id);
			}

			if (item.exclusive_for_class !== null) {
				extern.changeClass(item.exclusive_for_class);
				this.onChangedClass();
			}

			this.selectItem(item);
		},

		selectItemClickSound(selectedItem) {
			let selectSound;
			if (![ItemType.Hat, ItemType.Stamp].includes(selectedItem.item_type_id) && selectedItem.unlock !== 'default') {
				switch (selectedItem.item_type_id) {
					case ItemType.Grenade:
						selectSound = selectedItem.item_data.sound;
						break;
					case ItemType.Melee:
						const sounds = Object.keys(BAWK.sounds).filter(s => s.startsWith(selectedItem.item_data.meshName));
						selectSound = sounds[Math.floor(Math.random() * sounds.length)];
						break;
					default:
						selectSound = selectedItem.item_data.meshName + '_fire';
						break;
				}
			}
			BAWK.play(selectSound, '', 'ui_click');
		},

		onItemSelected: function (item) {
			if (this.$refs.buyItemPopup.isShowing) return;
			this.selectItem(item);
		},

		isPremItemInStore(item) {
			let hasItem = false;
			const isItem = this.premiumShopItems.find(i => i.isActive && i.itemId.id === item.id);
			if (hasValue(isItem)) {
				hasItem = true;
			}
			return hasItem;
		},

		selectItem: function (item) {

			if (!hasValue(item)) return;
			var selectingSame = hasValue(this.equip.selectedItem) && this.equip.selectedItem.id === item.id;
			var selectedId = selectingSame ? this.equip.selectedItem.id : null;
			var isWeapon = (item.item_type_id === ItemType.Primary || item.item_type_id === ItemType.Secondary || item.item_type_id === ItemType.Grenade || item.item_type_id === ItemType.Melee);
			var typeId = item.item_type_id;

			if (selectingSame) {
				if (this.isInShop) {
					this.hideItemForSale();
				} else {
					if (!isWeapon) {
						this.equipped[typeId] = null;
						extern.tryEquipItem(null, typeId)
					}
				}

				this.equip.selectedItem = null;
				this.updateEquippedItems();
				this.poseEquippedItems();
				this.renderStamp();
				return;
			}

			this.equipped[typeId] = item;

			if (item) {
				this.equip.selectedItem = item;

				if (this.currentEquipMode === this.equipMode.featured || this.currentEquipMode === this.equipMode.shop) {
					this.equip.selectedItemType = typeId;
					if (isWeapon) {
						this.equip.showingWeaponType = typeId
					} else {
						this.equip.showingWeaponType = null;
					}
				}

				// this.equip.selectedItemType = null;
				if (!this.ui.showHomeEquipUi) this.$emit('photo-booth-type-id');
			}

			if (!this.isInShop) extern.tryEquipItem(item, typeId);		
	
			if (hasValue(item)) {
				if (this.isInShop) {
					switch (item.unlock) {
						case "purchase":
						case "premium":
								this.offerItemForSale(item);
								this.hideItemForSpecial();
						break;
					}
				}
			} else {
				this.hideItemForSale();
				this.hideItemForSpecial();

			}

			this.selectItemClickSound(item);
			this.poseEquippedItems();

			if (item.item_type_id == ItemType.Stamp) {
				this.renderStamp();
			}
		},
		getButtonToggleClass: function (equipMode) {
			return (equipMode === this.currentEquipMode) ? 'btn_toggleon' : 'btn_toggleoff';
		},

		offerItemForSpecial: function(item) {
			return this.equip.physicalUnlockPopup.item = item;
		},

		hideItemForSpecial: function() {
			this.equip.physicalUnlockPopup.item = null;
		},

		offerItemForSale: function (item) {
			this.equip.buyingItem = item;
		},

		hideItemForSale: function () {
			this.equip.buyingItem = null;
			// this.equip.physicalUnlockPopup.item = null
		},

		onBuyItemClicked: function () {
			// If item is buying item show buyItemPopup or show physicalUnlockPopup
			if (this.equip.selectedItem && (this.isEquipModeShop || this.isOnEquipModeFeatured)) {
				this.equip.buyingItem = this.equip.selectedItem;
			}
			if (this.equip.buyingItem) {
				if (this.chwRewardIds.includes(this.equip.buyingItem.id)) {
					this.equip.chwRewardBuyItem = true;
				}
				this.$refs.buyItemPopup.toggle();
				extern.renderItemToCanvas(this.equip.buyingItem, this.$refs.buyItemCanvas)
			} else {
				this.$refs.physicalUnlockPopup.toggle()
			}
			BAWK.play('ui_popupopen');
		},

		onBuyItemConfirm: function () {
			if (this.equip.buyingItem.unlock === 'premium') {
				extern.buyProductForMoney(this.equip.buyingItem.sku[0]);
				return;
			} else {
				if (this.abTestInventory.enabled) {
					extern.aBTestInventoryTryReward();
				} else {
					extern.api_buy(this.equip.buyingItem, this.boughtItemSuccess, this.boughtItemFailed);
				}
			}
			BAWK.play('ui_playconfirm');
		},

		onBuyItemClose() {
			if (this.equip.chwRewardBuyItem) this.equip.chwRewardBuyItem = false;
		},

		boughtItemSuccess: function () {
			this.equip.selectedItem = this.equip.buyingItem;
			ga('send', 'event', {
				eventCategory: this.googleAnalytics.cat.itemShop,
				eventAction: this.googleAnalytics.action.shopItemPopupBuy,
				eventLabel: this.equip.buyingItem.name,
				eventValue: this.equip.selectedItem.price
			});
			var itemType = this.equip.selectedItem.item_type_id;
			if (itemType === ItemType.Primary || itemType === ItemType.Secondary || itemType == ItemType.Grenade || itemType == ItemType.Melee) {
				this.equip.showingWeaponType = itemType;
			}
			else {
				this.equip.showingWeaponType = null;
			}
			this.hideItemForSale();

			this.setup(itemType, this.isOnEquipModeFeatured);

			if (this.isEquipModeShop) {
				this.equip.showUnVaultedItems = [];
				setTimeout(() => this.equip.showUnVaultedItems = extern.getTaggedItems(this.ui.premiumFeaturedTag), 1);
			}
		},

		boughtItemFailed: function () {
			vueApp.showGenericPopup('p_buy_error_title', 'p_buy_error_content', 'ok');
			BAWK.play('ui_reset');
		},

		onRedeemClick: function () {
			this.$refs.redeemCodePopup.code = '';
			this.$refs.redeemCodePopup.toggle();
			BAWK.play('ui_popupopen');
		},

		onRedeemCodeConfirm: function () {
			if (this.equip.redeemCodePopup.code.toUpperCase() === 'D3LL0RKC1R') {
				this.giveStuffPopup.eggOrg = false;
				this.giveStuffPopup.rickroll = true;
				vueApp.showGiveStuffPopup('p_give_stuff_title');
			} else {
				this.giveStuffPopup.rickroll = false;
				this.giveStuffPopup.eggOrg = false;
				extern.api_redeem(this.equip.redeemCodePopup.code, this.redeemCodeSuccess, this.redeemCodeFailed);
			}
			BAWK.play('ui_playconfirm');
		},

		redeemCodeSuccess: function (eggs, items) {
			this.populateItemGridWithType(this.equip.selectedItemType);

			this.giveStuffPopup.eggs = eggs;
			this.giveStuffPopup.items = items;
			vueApp.showGiveStuffPopup('p_give_stuff_title', eggs, items);

			let itemString = '';
			this.giveStuffPopup.items.forEach(item => itemString += item.name);

			ga('send', 'event', {
				eventCategory: this.googleAnalytics.cat.redeem,
				eventAction: this.googleAnalytics.action.redeemed,
				eventLabel: `${itemString ? itemString : ''} ${this.giveStuffPopup.eggs ? this.giveStuffPopup.eggs + 'eggs' : ''}`
			});
		},

		redeemCodeFailed: function () {
			vueApp.showGenericPopup('p_redeem_error_title', 'p_redeem_error_content', 'ok');
			BAWK.play('ui_reset');
		},

		onPhysicalUnlockConfirm: function () {
			window.open(this.equip.physicalUnlockPopup.item.item_data.physicalItemStoreURL, '_blank');
		},

		onColorChanged: function (colorIdx) {
			this.equip.colorIdx = colorIdx;
			extern.setShellColor(this.equip.colorIdx);
			BAWK.play('ui_onchange');
		},

		onSwitchToSkinsClicked: function () {
			this.switchTo(this.equipMode.skins, this.equip.selectedItemType);
		},

		getVaultedItemsForGrid(selectFirstItem) {
			this.equip.showUnVaultedItems.splice(0, this.equip.showUnVaultedItems.length)
			this.$nextTick().then(() => {
				this.equip.showUnVaultedItems = extern.getTaggedItems(this.ui.premiumFeaturedTag);
				if (selectFirstItem) {
					this.equip.selectedItem = this.equip.showUnVaultedItems[0];
				}
			});
		},
		onPhotoboothClick: function () {
			if (extern.inGame) {
				return;
			}
			vueApp.switchToPhotoBoothUi();
			BAWK.play('ui_popupopen');
		},
		openProductBundlePopup(bundle) {
			if (this.equip.bundle.items.length === 0) {
				this.equip.bundle.items.length = 0;
				this.equip.bundle.items = bundle.items;
				this.equip.bundle.owned = bundle.isOwned;
				this.equip.bundle.price = bundle.price;
				this.equip.bundle.img = bundle.img;
				this.equip.bundle.name = bundle.name;
			}

			this.$refs.bundlePopup.toggle();
		},
		onBundlePopupConfirm() {
			if (this.equip.bundle.owned) {
				return this.equipAllItemsInbundle();
			}
			const activeBundle = extern.getActiveBundles();
			extern.buyProductForMoney(activeBundle[0].sku);
		},
		onBundlePopupClose() {
			this.equip.bundle.owned = false;
			this.equip.bundle.items.length = 0;
		},

		equipTryPremItemOn(item) {
			BAWK.play('ui_click');
			this.selectItem(item);
			extern.tryEquipItem(item)
		},

		equipAllItemsInbundle() {
			this.equip.bundle.items.forEach(item => {
				this.selectItem(item);
				extern.tryEquipItem(item)
			});
		},

		chwWatchAd() {
			this.$refs.buyItemPopup.toggle();	
			vueApp.chwDoIncentivized();
		},

		renderStamp() {
			if (this.$refs.stampCanvas === undefined) return;

			var item = this.equip.selectedItem;

			if (this.currentEquipMode !== this.equipMode.inventory) {
				item = this.equipped[ItemType.Stamp]
			}

			extern.renderItemToCanvas(item, this.$refs.stampCanvas);
		},
	},

	computed: {
		showShop() {
			return this.showScreen === this.screens.equip;
		},

		isOnEquipModeSkins() {
			return this.currentEquipMode === this.equipMode.skins;
		},

		isOnEquipModeFeatured() {
			return this.currentEquipMode === this.equipMode.featured;
		},

		isEquipModeInventory() {
			return this.currentEquipMode === this.equipMode.inventory;
		},

		isEquipModeShop() {
			return this.currentEquipMode === this.equipMode.shop;
		},

		isInShop: function () {
			return (this.isOnEquipModeSkins || this.isOnEquipModeFeatured || this.isEquipModeShop);
		},

		isOnShopInventoryLimited() {
			return (this.isOnEquipModeSkins || this.isEquipModeInventory || this.isOnEquipModeFeatured)
		},

		isOnShopInventory() {
			return (this.isOnEquipModeSkins || this.isEquipModeInventory)
		},

		getGridClass: function () {
			if (this.equip.selectedItemType !== 'tagged') {
				return`item-grid-${getKeyByValue(ItemType, this.equip.selectedItemType).toLowerCase()}`;
			}
		},

		gridCls() {
			return 'box_relative center_h overflow-x-hidden';
		},

		isEggStoreSaleItem() {
            return this.eggStoreItems.some( item => item['salePrice'] !== '');
		},
		isBuyingItemPrem() {
			if (!this.equip.buyingItem) {
				return;
			}
			return this.equip.buyingItem.unlock === 'premium';
		},
		showPurchasesUi() {
			return this.showShop && this.isEquipModeShop;
		},
		showShopUi() {
			return this.showShop && (this.isOnEquipModeSkins || this.isOnEquipModeFeatured || this.isEquipModeShop);
		},
		screenCls() {
			return `screen-${getKeyByValue(this.equipMode, this.currentEquipMode)}`;
		},
		isSelectedInUnVaulted() {
			return this.equip.showUnVaultedItems.some(item => item.id === this.equip.selectedItem.id);
		},
		showPriceTag() {
			return this.equip.buyingItem && (this.isOnEquipModeFeatured || this.isOnEquipModeSkins) && this.equip.showingItems.length > 0
		},
		showShopCart(){
			return this.isEquipModeInventory && this.ui.showHomeEquipUi;
		},
		photoBoothBtnTxt() {
			return this.ui.showHomeEquipUi ? this.loc.screen_photo_booth_menu : this.loc.screen_photo_booth_menu_close;
		},
		eggShopSortItems() {
			return this.eggStoreItems.sort((b, a) => {
				if (a.type === 'item' && b.type !== 'item') return 1;
				if (a.type !== 'item' && b.type === 'item') return -1;
				if (a.type === 'bundle' && b.type !== 'bundle') return 1;
				if (a.type !== 'bundle' && b.type === 'bundle') return -1;
				return 0;
			});
		},
		photoBoothBtnUi() {
			return {
				icon: this.ui.showHomeEquipUi ? 'fa-camera' : 'fa-times',
				cls: this.ui.showHomeEquipUi ? 'btn_blue bevel_blue' : 'btn_red bevel_red',
				txt: this.ui.showHomeEquipUi ? this.loc.screen_photo_booth_menu : this.loc.screen_photo_booth_menu_close
			}
		},
		chwButtonTxt() {
			if (this.chw.ready) {
				return 'chw_chance_to_win_item';
			} else {
				return 'chw_wait_msg';
			}
		},

		bundlePopupConfirmTxt() {
			return this.equip.bundle.owned ? this.loc.product_bundles_popup_owned_text : this.loc.p_buy_item_confirm;
		},
	},
	watch: {
		itemSearchVal(val, old) {
			this.debouncedSearch(val, old);
		},
	}
};
</script><script id="game-screen-template" type="text/x-template">
    <div :class="pauseScreenStateClass">
		<div ref="canvasWrap"></div>
		<!-- end .pause-screen-header -->

        <div ref="vipWrapper">
			<div id="chickenBadge" ref="chickenBadge" v-show="game.isPaused && isSubscriber && showScreen === screens.game"><img v-lazyload :data-src="upgradeBadgeUrl" class="lazy-load" /></div>
		</div>

		<div ref="gameUIWrapper">
			<div ref="gameUiInner" class="paused-game-ui z-index-1 centered_x fullwidth" v-show="showScreen === screens.game">
				<div ref="playerListWrapper" class="player-list-wrapper">
					<div ref="playerContainer" class="player__container" v-show="showScreen === screens.game">
						<div id="playerSlot" class="playerSlot" style="display: none">
							<div>
								<span></span> <!-- Name -->
								<span></span> <!-- Score -->
							</div>
							<div style="display: block;"></div> <!-- Icons -->
						</div>
						<!-- end .playerSlot -->
						<div id="playerList"></div>

						<div v-if="extern.GameOptions.value.flags & extern.GameFlags.locked" :key="gameOptionsPopup.options.flags" class="fa fa-lock fa-2x text_white"></div>
					</div>
					<!-- end .player__container -->
				</div>
				<!-- end .player_list_wrapper -->

				<!-- Scope -->
				<div id="scopeBorder">
					<div id="maskleft"></div>
					<div id="maskmiddle"></div>
					<div id="maskright"></div>
				</div>
				
				<!-- Best Streak -->
				<div id="shellStreakContainer" class="display-grid grid-column-1-auto align-items-center gap-sm">
					<span ref="shellStreakCap" id="shellStreakCaptionStreak" class="h1 text_yellow"><span>x</span>{{game.bestStreak.count}}</span>
					<div class="shellStreakCaptionWrap">
						<h1 id="shellStreakCaption">Best <br>Streak</h1>
							<!-- <p id="shellStreakMessage" v-show="game.streakMsg.msg" class="text_yellow">{{ game.streakMsg.msg }}</p> -->
					</div>
				</div>

				<!-- Challenge -->
				<div id="playerChallengeComplete" v-show="game.challengeMsg.showing" class="centered_x in-game-notification">
					<img id="playerChallengeImg" :src="game.challengeMsg.icon" alt="">
					<h2 id="playerChallengetitle" class="text_white nospace">{{game.challengeMsg.title}}</h2>
					<p class="text_yellow nospace">{{ loc.complete }}</p>
				</div>

				<!-- Team Scores -->
				<div id="teamScores" class="centered_x display-grid grid-auto-flow-column align-items-center gap-sm">
					<div id="teamScore2" class="teamScore red inactive box_relative">
							<i class="fas fa-egg"></i>
							<p id="teamScoreNum2" class="number centered_x">0</p>
					</div>
					<h3 class="text_white vs">VS</h3>
					<div id="teamScore1" class="teamScore blue inactive box_relative">
						<i class="fas fa-egg"></i>
							<p id="teamScoreNum1" class="number centered_x">0</p>
					</div>
					<!--<div>
							<img src="img/spatulaIcon.webp" style="width: 3em; transform: rotate(60deg)">
					</div>-->
				</div>

				<!-- Capture Icon -->
				<div ref="captureIconWrap" id="captureIconWrap">
					<div ref="captureIconContainer" id="captureIconContainer">
						<div id="captureInsideContainer">
							<div id="captureIconCaption">20M</div>
							<div id="captureRingBackground"></div>
							<div id="captureRingContainer">
								<div id="captureRing"></div>
							</div>
		
							<svg id="captureIcon" viewBox="0 0 53.6 36">
								<use href="img/kotc/crown.svg#crown" />
							</svg>
						</div>
					</div>
				</div>

				<!-- Hit Markers -->
				<div id="hitMarkerContainer">
					<div id="hitMarker0" class="hideme"></div>
					<div id="hitMarker1" class="hideme"></div>
					<div id="hitMarker2" class="hideme"></div>
					<div id="hitMarker3" class="hideme"></div>		
				</div>

				<!-- Reticle -->
				<div id="reticleDot"></div>
				<div id="reticleContainer" class="centered">
					<div id="redDotReticle"></div>
					
					<div id="crosshairContainer">
						<div id="crosshair0" class="crosshair normal"></div>
						<div id="crosshair1" class="crosshair normal"></div>
						<div id="crosshair2" class="crosshair normal"></div>
						<div id="crosshair3" class="crosshair normal"></div>
					</div>
	
					<div id="shotReticleContainer">
						<div id="shotBracket0" class="shotReticle border normal"></div>
						<div id="shotBracket1" class="shotReticle border normal"></div>
						<div id="shotBracket2" class="shotReticle fill normal"></div>
						<div id="shotBracket3" class="shotReticle fill normal"></div>
					</div>
	
					<div id="readyBrackets">
						<div class="readyBracket"></div>
						<div class="readyBracket"></div>
						<div class="readyBracket"></div>
						<div class="readyBracket"></div>
					</div>
				</div>
	
				<!-- Capture Zone progress -->
				<div id="captureContainer">
					<div class="captureScoreContainer">
						<svg class="captureCrown" viewBox="0 0 53.6 36">
							<use href="img/kotc/crown.svg#crown" fill="var(--ss-team-red-light)" />
						</svg>
	
						<div id="captureScoreRed" class="captureScore">0/5</div>
					</div>
	
					<div id="captureCenter">
						<div id="captureBarContainer">
							<div id="captureBar"></div>
						</div>
						<div id="captureBarText"></div>
					</div>
	
					<div class="captureScoreContainer">
						<svg class="captureCrown" viewBox="0 0 53.6 36">
							<use href="img/kotc/crown.svg#crown" fill="var(--ss-team-blue-light)" />
						</svg>
						<div id="captureScoreBlue" class="captureScore">0/5</div>
					</div>
				</div>
	
				<!-- Big Message Bar -->
				<div id="bigMessageContainer" style="display: none">
					<div id="bigMessageBar"> 
						<div id="bigMessage"></div>
						<div id="bigMessageCaption"></div>
					</div>
				</div>
	
				<!-- Weapon -->
				<div id="weaponBox">
					<div id="grenades">
						<img id="grenade3" class="grenade" src="img/ico_grenadeEmpty.webp?v=1"/>
						<img id="grenade2" class="grenade" src="img/ico_grenadeEmpty.webp?v=1"/>
						<img id="grenade1" class="grenade" src="img/ico_grenadeEmpty.webp?v=1"/>
					</div>
					<h2 id="weaponName"></h2>
					<h2 id="ammo" class="shadow_grey"></h2>
				</div>
	
				<!-- Health -->
				<div id="healthContainer" v-show="!game.isPaused && !ui.game.spectate">
					<svg class="healthSvg">
						<circle id="hardBoiled-bar" class="healthBar-hardBoiled healthBar-area" cx="50%" cy="50%" r="2.85em" />
						<circle id="hardBoiled-stroke" class="healthBar-hardBoiled-stroke healthBar-area" cx="50%" cy="50%" r="2.4em" />
						<circle id="healthBar" class="healthBar healthBar-area" cx="50%" cy="50%" r="2.15em" />
						<circle class="healthYolk" cx="50%" cy="50%" r="1.35em" />
					</svg>
	
					<div id="healthHp" class="centered">100</div>
				</div>
				
				<div id="egg-breaker-wrap" class="egg-breaker-wrap display-grid box_absolute font-nunito grid-auto-flow-column gap-1">
					<shell-streak-msg v-for="msg in game.shellStreakTimers " :loc="loc" :msgId="msg.msgId" :msg="msg.msg"></shell-streak-msg>
				</div>
				<!-- egg-breaker-wrap end -->
				<icon id="spatulaPlayer" name="ico_spatula"></icon>
	
				<!-- Grenade throw power -->
				<div id="grenadeThrowContainer">
					<div id="grenadeThrow"></div>
				</div>

				<div id="kill-death-box" ref="killDeathBox" v-show="game.ingameNotification.showing" class="in-game-notification centered_x">
					<img v-show="game.ingameNotification.item.type !== 2" src="img/ico_streak.webp" alt="" class="centered_x kill-death-box-img" />
					<span v-show="game.ingameNotification.item.type == 2" class="h1 text_yellow centered_x"><span>x</span>{{game.ingameNotification.item.streak}}</span>
					<h2 v-show="game.ingameNotification.item.type == 2" class="nospace text_white">{{ loc.ks_shell_streak }}!</h2>
					<div class="kill-death-msg" ref="killMsg" v-show="game.ingameNotification.item.type !== 2" :class="game.ingameNotification.item.style" v-html="game.ingameNotification.item.msg"></div>
					<p v-show="game.ingameNotification.item.type == 2" class="nospace text_yellow text-uppercase">{{ game.ingameNotification.item.msg }}</p>
				</div>

				<transition name="fade">
					<div id="cts-message" v-show="game.ctsMsg.showing" :class="game.ctsMsg.teams[game.ctsMsg.team]" class="centered_y in-game-notification light-dark display-grid grid-auto-flow-column gap-1 align-items-center">
						<div>
							<h1 class="team-title nospace text-right">{{ game.ctsMsg.teams[game.ctsMsg.team] }}</h1>
							<p class="nospace text_white text-right">{{ loc[game.ctsMsg.msg] }}</p>
						</div>
						<icon class="icon-spatula" name="ico_spatula"></icon>
					</div>
				</transition>
	
				<!-- Game messages -->
				<div id="gameMessage"></div>

				<!-- Kill ticker -->
				<div ref="killTickerWrapper">
					<div ref="killTicker" id="killTicker" class="chat"></div>
				</div>

				<!-- Spectator controls -->
				<div id="spectate">
					<div class="h4 margins_sm">{{ loc.ui_game_spectating }}</div>

					<div v-if="ui.game.spectatingPlayerName">
						<div class="h1 margins_sm">{{ ui.game.spectatingPlayerName }}</div>
						<div>
							<span class="fas fa-arrow-up"></span>
							&nbsp;/&nbsp;
							<span class="fas fa-arrow-down"></span>
							&nbsp;{{ loc.ui_game_spectate_select }}
						</div>
					</div>

					<div>{{ spectateControls }}</div>
				</div>

				<div ref="spectateWrap" class="spectate-wrapper">
					<button ref="spectateBtn" v-show="!isRespawning && game.isPaused && showScreen === screens.game && delayTheCracking" @click="onSpectateClicked()" class="ss_button btn_blue bevel_blue btn_sm pause-screen-btn-spectate" :disabled="isRespawning" :title="loc.p_pause_spectate">
						<i class="fas fa-eye fa-2x"></i>
					</button>
				</div>
			</div>
		</div>
		<!-- ref gameUIWrapper -->

		<div id="chw-game-screen" :class="{'has-announcement': announcementMessage}">
		</div>
		
		<div ref="chatWrapper" :class="[{'chat-hidden': !chatEnabled}]" class="chat-wrapper pause-ui-element box_absolute roundme_lg">
			<div ref="announcementMsg" v-show="announcementMessage" id="announcement_message" class="font-nunito text_white"><span class="text_yellow">Announcement: </span>{{ announcementMessage }}</div>
			<div v-show="!chatEnabled" class="paddings_md">
				<h4 class="text_white nospace">{{ loc.ingame_chat_hidden }}</h4>
				<p @click="onSettingsClicked(true)" class="nospace text_white">{{ loc.ingame_chat_open_settings }}</p>
			</div>
			<div ref="chatContainer" v-show="chatEnabled" class="chat-container">
				<div id="chatOut" class="chat roundme_sm"></div>
				<input id="chatIn" class="chat roundme_sm" maxlength=64 tabindex=-1 v-bind:placeholder="loc.ingame_press_tab_to_exit" onkeydown="extern.onChatKeyDown(event)" onclick="extern.startChat(event)" onblur="extern.stopChat(event)"></input>
			</div>
		</div>
        <!-- Chat -->

		<!-- Ingame UI Stuff --> 
		<div id="inGameUI" class="roundme_lg">
			<div id ="serverAndMapInfo">
				<h5 class="nospace title text-right">{{ loc.map }}</h5>
				<p class="name">{{ game.mapName }}</p>
				<h5 class="nospace title text-right">{{ loc.server }}</h5>
				<p class="name">{{ serverLoc }}</p>
			</div>
			<div id="readouts">
               <h5 class="nospace title">{{ loc.ui_game_fps }}</h5>
				<p id="FPS" class="name"></p>
                <h5 class="nospace title">{{ loc.ui_game_ping }}</h5>
				<p id="ping" class="name"></p>
			</div>
		</div>

        <!-- Popup: Mute/Boot Player -->
        <small-popup id="playerActionsPopup" ref="playerActionsPopup" :hide-confirm="true" @popup-opened="sharedPopupOpened">
            <template slot="header">{{ playerActionsPopup.playerName }}</template>
            <template slot="content">
                <div v-if="playerActionsPopup.vipMember" class="vip-member-wraper display-grid align-items-center grid-column-1-2 ss_marginbottom_xl">
                    <figure class="player-action-vip-img center_h">
						<img v-lazyload :data-src="ui.lazyImages.vipEmblem" class="lazy-load center_h" alt="Shell Shockers VIP">
                    </figure>
                    <div>
                        <h6 class="roundme_sm shadow_blue4 ss_margintop ss_marginbottom">{{loc.ui_game_playeractions_vip_member}}</h6>
                        <button v-if="!isSubscriber" class="ss_button btn_pink bevel_pink fullwidth" @click="openVipPopup">{{loc.ui_game_playeractions_join_vip}}</button>
                    </div>
                </div>
                <!-- .vip-member-wraper -->
                <p>{{ loc.ui_game_playeractions_header }}</p>
                <button v-if="playerActionsPopup.social" class="ss_button btn_medium btn_yolk bevel_yolk fullwidth" @click="onClickCreator(playerActionsPopup.social.url)"><i class="fab" :class="playerSocial"></i> {{loc.ui_game_playeractions_creator}}</button>
                <h4 class="ss_button btn_medium btn_blue bevel_blue" v-on:click="onMuteClicked">{{ muteButtonLabel }}</h4>
				<h4 class="ss_button btn_medium btn_red bevel_red" v-on:click="onReportActionClicked">{{ loc.ui_game_playeractions_report }}</h4>
                <h4 class="ss_button btn_medium btn_yolk bevel_yolk" v-if="extern.isGameOwner" v-on:click="onBootClicked">{{ loc.ui_game_playeractions_boot }}</h4>
				<h4 class="ss_button btn_medium btn_pink bevel_pink" v-if="extern.adminRoles & 4" v-on:click="onBanActionClicked">{{ loc.ui_game_playeractions_ban }}</h4>
				<h4 class="ss_button btn_medium btn_green bevel_green" v-if="extern.adminRoles & 64" v-on:click="onInfoClicked">Info</h4>
            </template>
            <template slot="cancel">{{ loc.cancel }}</template>
        </small-popup>

		<!-- Popup: Ban Player -->
        <small-popup id="banPlayerPopup" ref="banPlayerPopup" :hide-confirm="true" @popup-opened="sharedPopupOpened" @popup-closed="sharedPopupClosed">
            <template slot="header">Ban Player</template>
            <template slot="content">
				<h5 class="text_yellow">{{ playerActionsPopup.playerName }}</h5>
                <input ref="banReason" type="text" placeholder="Reason" class="ss_field ss_margintop ss_marginbottom fullwidth" @focus="$event.target.select()">
				<select ref="banDuration" class="ss_field">
					<option v-for="d in banDurations" v-bind:value="d.value" v-html="d.label"></option>
				</select>
				<h4 class="ss_button btn_medium btn_green bevel_green" v-if="extern.adminRoles & 4" v-on:click="onBanClicked">{{ loc.ui_game_playeractions_ban }}</h4>
            </template>
            <template slot="cancel">{{ loc.cancel }}</template>
        </small-popup>

		<!-- Popup: Report Player -->
		<small-popup id="reportPlayerPopup" ref="reportPlayerPopup" :hide-confirm="true" @popup-opened="sharedPopupOpened" @popup-closed="sharedPopupClosed">
            <template slot="header">{{ loc.report_player_title }}</template>
            <template slot="content">
				<h5 class="text_yellow">{{ playerActionsPopup.playerName }}</h5>
				<p v-for="(r, i) in reportReasons">
					<label class="ss_checkbox label"> {{ loc[r.locKey] }}
						<input type="checkbox" v-model="reportPlayerPopup.checked[i]">
						<span class="checkmark"></span>
					</label>
				</p>
				<br>
				<button class="ss_button btn_medium btn_green bevel_green" :disabled="!isReportFilled" v-on:click="onReportClicked">{{ loc.ui_game_playeractions_report }}</button>
            </template>
            <template slot="cancel">{{ loc.cancel }}</template>
        </small-popup>

		<!-- Popup: Switch Team -->
		<small-popup id="switchTeamPopup" ref="switchTeamPopup" :overlay-close="false" @popup-confirm="onSwitchTeamConfirm" @popup-opened="sharedPopupOpened">
			<template slot="header">{{ loc.p_switch_team_title }}</template>
			<template slot="content">
                <h4 class="roundme_sm" :class="newTeamColorCss">{{ newTeamName }} <i class="fa fa-flag"></i></h4>
				<p>{{ loc.p_switch_team_text }}</p>
			</template>
			<template slot="cancel">{{ loc.no }}</template>
			<template slot="confirm">{{ loc.yes }}</template>
		</small-popup>

		<!-- Popup: Share Link -->
		<small-popup id="shareLinkPopup" ref="shareLinkPopup" :popup-model="game.shareLinkPopup" @popup-confirm="onShareLinkConfirm" @popup-opened="sharedPopupOpened">
			<template slot="header">{{ loc.p_sharelink_title }}</template>
			<template slot="content">
				<p>{{ loc.p_sharelink_text }}</p>
				<p><input ref="shareLinkUrl" type="text" class="ss_field ss_margintop ss_marginbottom fullwidth" v-model="game.shareLinkPopup.url" @focus="$event.target.select()" @popup-opened="sharedPopupOpened" @popup-closed="sharedPopupClosed"></p>
			</template>
			<template slot="cancel">{{ loc.close }}</template>
			<template slot="confirm">{{ loc.p_sharelink_copylink }}</template>
		</small-popup>

		<div ref="pausePopupWrap" id="pausePopupWrap">
			<div v-show="game.pauseScreen.showMenu" ref="pausePopup" class="pause-container centered">
				<div id="respawn-group" class="display-grid">
				<display-ad id="shellshock-io_respawn_three" ref="headerDisplayAdGame" class="display-ad-header" :ignoreSize="true" :adUnit="displayAd.adUnit.respawnThree" adSize="728x90" :check-products="checkProducts"></display-ad>
					<div id="respawn-menu">
						<div class="display-grid grid-column-2-eq gap-sm">
							<player-challenge-list :loc="loc" :challenges="player.challenges" :challenge-data="player.challengeDailyData" :timers="player.challengeTimer" :in-game="true" @challengeReroll="challengeReroll"></player-challenge-list>
							<div class="pause-ad-wrap display-grid align-items-center">
								<div class="pause-screen-content pause-bg roundme_md box_relative center_h">
									<section id="btn_horizontal" class="pause-game-weapon-select pause-popup--btn-group">
										<div class="media-tab-container display-grid align-items-center ss_marginbottom bg_blue3">
											<h4 class="common-box-shadow text-shadow-black-40 text_white">{{loc.p_weapon_title}}</h4>
										</div>
										<weapon-select-panel
											ref="weaponSelect"
											id="weapon_select"
											:loc="loc"
											:current-class="classIdx"
											:account-settled="true"
											:play-clicked="false"
											@changed-class="pauseWeaponSelect"
											:current-screen="showScreen"
											:screens="screens"
										></weapon-select-panel>
									</section>
								</div>
								<!-- end .pause-screen-content -->
								<!-- <div class="pause-screen-play-btn center_h text-center"> -->
								<button v-if="!extern.observingGame" @click="onPlayClicked()" class="ss_button btn_big btn-dark-bevel btn-respawn" :class="playBtnColor" :disabled="isRespawning">
									<i v-if="delayTheCracking" v-show="!isRespawning" class="fa fa-play"></i>{{ playBtnText }} <span style="display: inline-block; font-size: 0.4em;">{{ playBtnAdBlockerText }}</span>
								</button>
								<button v-if="delayTheCracking" v-show="isTeamGame" @click="onSwitchTeamClicked" class="ss_button btn_big btn_team_switch btn-dark-bevel btn-respawn" :class="teamColorCss">
									<div class="display-grid grid-column-1-2 align-items-center">
										<i class="fa fa-flag fa-2x"></i>
										<div v-html="teamName" class="team-switch-text text-left"></div>
									</div>
								</button>
								<h1 class="text_white" v-if="extern.observingGame">OBSERVING - SPECTATE ONLY</h1>
								<!-- </div> -->
							</div>
						</div>
						<!-- respawn menu-->
					</div>
					<div id="respawn-ad-two">
						<div v-if="!isSubscriber" class="respawn-container respawn-two display-grid">
							<display-ad id="shellshockers_respawn_banner_2_ad" ref="respawnTwoDisplayAd" class="pauseFiller" :ignoreSize="false" :adUnit="displayAd.adUnit.respawnTwo" adSize="300x250" :check-products="checkProducts"></display-ad>
						</div>
						<!-- .respawn-two smaller-->
					</div>
					<div id="respawn-ad-one">
						<div class="pause-screen-wrapper grid-span-2-start-1" :class="pauseScreenWrapGrid">
							<div ref="pauseContainer" class="pause-popup--container box_relative roundme_lg display-grid gap-1">
								<!-- wrapper -->
								<div v-if="!isSubscriber" class="respawn-container respawn-one display-block">
									<display-ad id="shellshockers_respawn_banner-new_ad" ref="respawnDisplayAd" class="pauseFiller" :ignoreSize="false" :adUnit="displayAd.adUnit.respawn" adSize="728x90" :check-products="checkProducts"></display-ad>
								</div>
								<!-- .respawn-one -->
							</div>
							<!-- end .pause-popup--container -->
						</div>
						<!-- end .pause-screen-wrapper -->
					</div>
				</div>
			</div>
		</div>
	</div>	
	</script>

<script id="shell-streak-msg" type="text/x-template">
	<div :id="htmlId" :class="htmlClass">
		<div class="egg-breaker-container display-grid">
			<div id="egg-breaker-icon-wrap" class="box_relative">
				<div v-if="!showRestock" class="box_absolute">						
					<svg id="Layer_2" data-name="Layer 2" class="egg-breaker-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 112.49 135.74"><path class="cls-1" d="m64.53.31-4.95 14.66 16.84 5.2-26 27.81 7.69-23.51H42.74L49.14 0C21.43 6.67 0 50.83 0 79.49 0 96.65 7.69 112 19.81 122.32l15.92-16.8-2.5 25.28a55.973 55.973 0 0 0 23.02 4.93c6.03 0 11.84-.96 17.29-2.72l-2.76-11.5H57.67v-14.98l5.65 9.04 16.96-3.84 7.56 14.29c14.88-10.12 24.66-27.19 24.66-46.54C112.49 51.25 91.66 7.94 64.53.31Z" id="Layer_1-2" data-name="Layer 1"/></svg>
					<div :id="htmlClass" class="centered">15</div>
				</div>
			</div>
			<div class="egg-breaker-msg text-uppercase" :class="elStyle">
				<span v-if="!showRestock" class="font-sigmar x-two-msg"><span>x</span>2</span>
				<icon v-if="showRestock" name="ico-shell-streak-restock" class="egg-breaker-icon shell-streak-restock-icon"></icon>
				{{ msgLoc }}
			</div>
		</div>
	</div>
</script>


<script>
const CompShellStreakMsg = {
    template: '#shell-streak-msg',
	props: ['loc', 'msgId', 'svg', 'msg'],
    computed: {
		htmlId() {
			return 'shellStreak-' + this.msgId;
		},
		htmlClass() {
			return `shellStreak-${this.msgId}-timer`;
		},
		msgLoc() {
			return this.loc[this.msg];
		},
		showRestock() {
			return this.msgId === 'restock';
		},
		elStyle() {
			return this.showRestock ? 'f_row align-items-center' : '';
		}

	},
	watched: {
	}
};
</script>


<script>
var comp_game_screen = {
    template: '#game-screen-template',
    components: {
        'account-panel': comp_account_panel,
        'weapon-select-panel': comp_weapon_select_panel,
		'weapon-select-panel': comp_weapon_select_panel,
		'player-challenge-list': CompPlayerChallengeList,
		'shell-streak-msg': CompShellStreakMsg,
		// 'chw': CompChwHomeScreen
    },
    props: ['kname', 'kdname'],
	data: function () {
		return vueData;
    },
    created: function () {
        this.isPoki = pokiActive;
    },
    methods: {
		sharedPopupOpened(id) {
			this.game.openPopupId = id ? id : '';
		},

		sharedPopupClosed(id) {
		},

        showGameMenu: function () {

			if (this.abTestInventory.enabled) {
				return;
			}

			vueApp.setDarkOverlay(false);
			this.game.pauseScreen.showMenu = true;
            this.game.gameType = extern.gameType;

			if (this.showScreen === this.screens.game) {
				vueApp.showRespawnDisplayAd();
				vueApp.hideHeaderAd();
			}

            setTimeout(() => vueApp.disableRespawnButton(false), 500);
			vueApp.gameUiAddClassForNoScroll();
			
            addEventListener('gamepadbuttondown', this.onControllerButton);
            this.crazyAdsRespawn();
			vueApp.hideShareLinkPopup();
			
			this.pauseUi();
			
			vueApp.setPause(true);

			addEventListener('resize', this.announcementMsg());

            this.ui.showCornerButtons = true;
			this.ui.game.spectate = false;

			if (this.announcementMessage) {
				this.announcementMsg();
			}
        },

        announcementMsg() {
            this.$nextTick(() => {
                const fontSize = parseFloat(getComputedStyle(this.$refs.announcementMsg).fontSize);
                const heightInPx = this.$refs.announcementMsg.clientHeight;
                const heightInEm = heightInPx / fontSize;
                this.$refs.chatWrapper.style.height = `calc(var(--ss--chat-height) + ${heightInEm}em)`;
            });
        },
		announcementMsgReset() {
			if (this.game.isPaused) {
				this.$refs.chatWrapper.style.height = 'calc(var(--ss--chat-height) + 0em)';
			} else {
				this.$refs.chatWrapper.style.height = 'auto';
			}
		},

        delayGameMenuPlayButtons() {
            setTimeout(() => {
                this.delayTheCracking = true;
				extern.prepRespawnButton();
            }, 3000);
        },

        hideGameMenu: function () {
            if (!extern.inGame)  {
                return;
            }
			this.game.pauseScreen.showMenu = false;
            crazySdk.clearAllBanners(); // Per CG's request
            vueApp.gameUiAddClassForNoScroll();
			vueApp.hideRespawnDisplayAd();

			if (!this.game.isPaused) {
				this.announcementMsgReset();
			}

            removeEventListener('gamepadbuttondown', this.onControllerButton);
			// removeEventListener('resize', this.pauseScreenPlayerListOverflowCheck);
        },

        onLeaveGameConfirm: function () {
			if (this.showScreen === this.screens.equip) {
				vueApp.onBackClick();
			}
			this.resetUi();
            this.leaveGame();
            this.delayTheCracking = false;
        },

        onLeaveGameCancel: function () {
            this.showGameMenu();
        },

        leaveGame: function () {
            // clientGame.js manipulates chickenBadge element directly to hide/show it
			this.resetMsgs();
			this.clearMsgTimers();
			removeEventListener('resize', this.pauseScreenPlayerListOverflowCheck);
            vueApp.disablePlayButton(false);
            this.$refs.chickenBadge.style.display = 'none';
            document.body.style.overflow = 'visible';
            window.scrollY = 0;
            this.hidePopupsIfGameCloses();
            extern.leaveGame(this.afterLeftGame);
			this.player.challengeTimer.played = 0;
			this.player.challengeTimer.alive = 0;
            vueData.ui.showCornerButtons = true;
            // OneSignal elements are not part of the Vue app
            var oneSignalBell = document.getElementById('onesignal-bell-container');
            if (oneSignalBell) {
                oneSignalBell.style.display = 'none';
            }

        },

        hidePopupsIfGameCloses: function() {
            const gamePopups = vueApp.$refs.gameScreen.$children;
            if (Array.isArray(gamePopups)) {
                gamePopups.forEach( gamePopup => {;
                    if ( gamePopup.isShowing === true && gamePopup.$el.id !== 'pausePopup' ) {
                        gamePopup.close();
                        console.log(`Closing ${gamePopup.$el.id}`);
                    }
                });
            }
        },

        afterLeftGame: function () {
			vueApp.showSpinner();
			setTimeout(() => {
				// extern.resize();
				vueApp.hideSpinner();
			}, 200);
		    vueApp.switchToHomeUi();
        },

		onHelpClicked: function () {
            // this.hideGameMenu();
            vueApp.showHelpPopup();
            BAWK.play('ui_popupopen');
        },

        onShareLinkClicked: function () {
            extern.inviteFriends();
            BAWK.play('ui_popupopen');
        },

        onSettingsClicked: function (openMisc) {
			if (!openMisc) openMisc = false;
            // this.hideGameMenu();
            vueApp.showSettingsPopup();
            BAWK.play('ui_popupopen');
			if (openMisc) vueApp.onSettingsPopupSwitchTabMisc();
        },

        onShareLinkConfirm: function () {
            extern.copyFriendCode(this.$refs.shareLinkUrl);
        },

        onEquipClicked: function () {
            this.game.pauseScreen.wasGameInventoryOpen = true;
            this.game.pauseScreen.classChanged = false;
            this.gaSend('inventory');
            vueApp.openEquipSwitchTo(this.equipMode.inventory);
            BAWK.play('ui_equip');
        },

        onSwitchTeamClicked: function () {
            // this.hideGameMenu();
            BAWK.play('ui_popupopen');
            this.$refs.switchTeamPopup.show();
        },

        onSwitchTeamConfirm: function () {
            extern.switchTeam();
        },

        onControllerButton: function (e) {
            switch (e.detail) {
                case '9':
                    if (document.hasFocus() && !this.isRespawning && this.delayTheCracking) {
                        this.onPlayClicked();
                    }
                    break;

                case '4':
                case '6':
                case '14':
                    vueData.classIdx = Math.max(0, vueData.classIdx - 1);
                    this.$refs.weaponSelect.onWeaponSelect(vueData.classIdx);
                    break;

                case '5':
                case '7':
                case '15':
                    vueData.classIdx = Math.min(6, vueData.classIdx + 1);
                    this.$refs.weaponSelect.onWeaponSelect(vueData.classIdx);
                    break;
            }
        },

        gaSendOnClassChange() {
            if (!this.game.pauseScreen.wasGameInventoryOpen && this.game.pauseScreen.classChanged) {
                ga('send', 'event', 'respawn-popup', 'classClick', Object.keys(CharClass).find(key => CharClass[key] === vueApp.classIdx));
            }

            // reset for good measure
            this.game.pauseScreen.wasGameInventoryOpen = false;
            this.game.pauseScreen.classChanged = false;
        },

		onPlayClicked() {
			if ((!this.delayTheCracking && !this.isRespawning) || (this.delayTheCracking && this.isRespawning) || this.game.disableRespawnButton) {
				return;
			}

            vueApp.disableRespawnButton(true);
            vueData.ui.showCornerButtons = false;
            extern.respawn();
            BAWK.play('ui_playconfirm');
            this.gaSendOnClassChange();
		},

        onSpectateClicked: function () {
            this.gaSend('spectate');
            this.hideGameMenu();
            vueData.ui.showCornerButtons = false;
            extern.enterSpectatorMode();
			this.ui.game.spectate = true;
            BAWK.play('ui_playconfirm');
        },

        showPlayerActionsPopup: function () {
            // this.hideGameMenu();
            this.$refs.playerActionsPopup.show();
        },

        onMuteClicked: function () {
            this.$refs.playerActionsPopup.hide();
            this.playerActionsPopup.muteFunc();
        },

		onReportActionClicked: function () {
			for (let i = 0; i < this.reportPlayerPopup.checked.length; i++) {
				this.reportPlayerPopup.checked[i] = false;
			}

			this.$refs.playerActionsPopup.hide();
			this.$refs.reportPlayerPopup.show();
		},

		onReportClicked: function () {
			this.$refs.reportPlayerPopup.hide();

			let reasons = 0;

			for (let i = 0; i < this.reportPlayerPopup.checked.length; i++) {
				if (this.reportPlayerPopup.checked[i]) {
					reasons |= (1 << i);
				}
			}

			this.playerActionsPopup.reportFunc(reasons);
		},

        onBootClicked: function () {
            this.$refs.playerActionsPopup.hide();
            this.playerActionsPopup.bootFunc();
        },

		onBanActionClicked: function () {
			this.$refs.playerActionsPopup.hide();
            this.$refs.banPlayerPopup.show();
        },

		onBanClicked: function () {
			this.$refs.banPlayerPopup.hide();
			this.playerActionsPopup.banFunc(this.$refs.banReason.value, this.$refs.banDuration.value);
		},

		onInfoClicked: function () {
            this.$refs.playerActionsPopup.hide();
            this.playerActionsPopup.infoFunc();
        },

        resizeBannerAdTagForGame: function() {
            const pauseAdPlacement = document.getElementById('pauseAdPlacement');
            const rect = document.getElementById('pausePopup').getBoundingClientRect();

            pauseAdPlacement.style.top = (rect.height).toString() + 'px';
        },
        earnInGameReward() {
            // this.hideGameMenu();
            vueApp.setDarkOverlay(true);
            this.pokiRewardReady = false;
             this.isPokiNewRewardTimer = false;
            extern.api_inGameReward(this.inGameRewardSuccessCallback, this.inGameRewardFailedCallback, this.rewardReachedDailyLimits);
            extern.setVolume(0);
        },
        inGameRewardSuccessCallback() {
            extern.pokiRewardedBreak(this.inGameRewardIsGranted, this.inGameRewardFailedCallback);
        },
        inGameRewardIsGranted(rewardValue) {
            console.log('inGameRewardSuccessCallback');
            this.isPokiNewRewardTimer = true;
            vueApp.showGiveStuffPopup('reward_title', rewardValue, '');
            ga('send', 'event', 'Poki', 'Rewarded Video', 'Reward Success', this.pokiRewNum);
            this.pokiRewNum ++;
        },
        inGameRewardFailedCallback() {
            vueApp.showGenericPopup('p_redeem_error_title', 'in_game_reward_try_again', 'ok');
            this.isPokiNewRewardTimer = false;
            ga('send', 'event', 'Poki', 'Rewarded Video', 'Failed');
        },
        rewardReachedDailyLimits() {
            vueApp.showGenericPopup('in_game_reward_title', 'in_game_reward_try_again', 'ok');
            this.isPokiNewRewardTimer = false;
            localStore.setItem('inGameRewardLimitDate',  Date.now());
            extern.setVolume();
            ga('send', 'event', 'Poki', 'Rewarded Video', 'Reached Daily Limit');
        },

        pokiTimers(value, milliseconds) {
            let pokiSetTimer;

            if (value === false) {
                clearTimeout(pokiSetTimer);
                console.log('cancelTimer');
                return;
            }
            pokiSetTimer = setTimeout(() => this.pokiRewardReady = true, milliseconds);
        },

        pauseWeaponSelect() {
            this.game.pauseScreen.wasGameInventoryOpen = false;
            this.game.pauseScreen.classChanged = true;
            vueApp.$refs.equipScreen.onChangedClass();
        },
        songHasChanged() {
            setTimeout(() => this.songChanged = false , 2000);
        },

        // So crazy games requires an array for multiple display ad calls on the same screen
        crazyAdsRespawn() {
            this.cGrespawnBannerErrors = 0;
			this.$nextTick(() => {
				crazySdk.requestResponsiveBanner('shellshock-io_respawn_three');
				crazySdk.requestResponsiveBanner('shellshockers_respawn_banner-new_ad');
				crazySdk.requestResponsiveBanner('shellshockers_respawn_banner_2_ad');
			});
        },

        onClickCreator(url) {
            window.open(url, )
        },

        openVipPopup() {
            this.$refs.playerActionsPopup.hide();
            vueApp.showSubStorePopup();
        },
		gaSend(label) {
			if (!label) return;
            ga('send', 'event', 'respawn-popup', 'click', label);
		},
		playIncentivizedAd() {
			vueApp.playIncentivizedAd();

		},
		onEggShopClicked() {
			vueApp.openEquipSwitchTo(this.equipMode.shop);
		},
		onFullscreenClicked() {
			extern.toggleFullscreen();
		},
		pauseUi() {
			this.resetMsgs(true);
			this.clearMsgTimers();
			// vueApp.$refs.gameCanvas.appendChild(this.$refs.gameUiInner);
		},
		resetUi() {
			// this.$refs.pausePopupWrap.appendChild(this.$refs.pausePopup);
		},
		resetMsgs(saveStreak) {
			// Reset the killDeathMsg object
			this.game.killDeathMsg = {
				showing: false,
				msgs: [],
				msg: '',
				style: '',
				timer: null
			};

			// Reset the challengeMsg object
			this.game.challengeMsg = {
				showing: false,
				msgs: [],
				icon: '',
				title: '',
				timer: null
			};

			// Reset the ctsMsg object properties
			this.game.ctsMsg.showing = false;
			this.game.ctsMsg.team = 0;
			this.game.ctsMsg.msg = '';
			this.game.ctsMsg.timer = null;

			// Reset the streakMsg object
			this.game.streakMsg = {
				showing: false,
				msg: '',
				count: 0,
				timer: null
			};

			if (!saveStreak) {
				// Reset the bestStreak object
				this.game.bestStreak = {
					count: 0,
					timer: null
				};
			}

			// Reset the ingameNotification object
			this.game.ingameNotification = {
				item: {
					type: 0,
					msg: '',
					streak: 0,
					style: ''
				},
				showing: false,
				timer: null,
				multiTimer: null
			};
		},

		clearMsgTimers() {
			if (this.game.killDeathMsg.timer) clearTimeout(this.game.killDeathMsg.timer);
			if (this.game.challengeMsg.timer) clearTimeout(this.game.challengeMsg.timer);
			if (this.game.ctsMsg.timer) clearTimeout(this.game.ctsMsg.timer);
			if (this.game.streakMsg.timer) clearTimeout(this.game.streakMsg.timer);
			if (this.game.bestStreak.timer) clearTimeout(this.game.bestStreak.timer);
			if (this.game.ingameNotification.timer) clearTimeout(this.game.ingameNotification.timer);
			if (this.game.ingameNotification.multiTimer) clearTimeout(this.game.ingameNotification.multiTimer);
			if (this.game.inGameNotification.timer) clearTimeout(this.game.inGameNotification.timer);
		},

		onTutorialPopupClick() {
            this.gaSend('tutorial');
			vueApp.onTutorialPopupClick();
		},
		onLockClicked () {
			if (!extern.gameIsOwnerLocked) {
				extern.sendChat('/lock');
				extern.gameIsOwnerLocked = true;
			}
			else {
				extern.sendChat('/unlock');
				extern.gameIsOwnerLocked = false;
			}
		},

		challengeReroll(id) {
			extern.playerChallenges.reroll(id);
		},
		killDeathMsg() {
			if (this.game.killDeathMsg.msgs.length > 0) {

				if (this.game.killDeathMsg.msgs[0].type === 0) {
					// show kill
					this.killDeathMsg.msg = this.loc['ui_game_youkilled'].format(this.game.killDeathMsg.msgs[0].name)
					this.killDeathMsg.style = 'killed';
				} else {
					// show death
					this.killDeathMsg.msg = this.loc['ui_game_killedby'].format(this.game.killDeathMsg.msgs[0].name)
					this.killDeathMsg.style = 'died';
				}
				
				this.game.killDeathMsg.showing = true;
				this.game.killDeathMsg.msgs.shift();

				setTimeout(() => {
					this.game.killDeathMsg.showing = false;
					this.killDeathMsg();
				}, 4000);

			}
		},
		challengeMsg() {
			const { challengeMsg } = this.game;

			if (challengeMsg.msgs.length > 0) {
				BAWK.play('challenge_notify');

				challengeMsg.icon = '';
				challengeMsg.title = '';
				
				// Destructure the first message directly, avoiding repetitive access
				const { icon, title } = challengeMsg.msgs.shift();
				challengeMsg.icon = icon;
				challengeMsg.title = title;
				challengeMsg.showing = true;

				// Use an arrow function to maintain the context of `this` naturally
				setTimeout(() => {
					challengeMsg.showing = false;
					this.challengeMsg();  // Recursive call to process the next message
				}, 2000);
			}
		},
		ctsCapturedMsg() {
			this.game.ctsMsg.showing = true;
			// if timer is null, set it
			if (this.game.ctsMsg.timer == null) {
				this.game.ctsMsg.timer = setTimeout(() => {
				this.game.ctsMsg.showing = false;
				this.game.ctsMsg.timer = null;
				}, 3000);
			} else {
				// if timer is not null, clear it and set it again
				clearTimeout(this.game.ctsMsg.timer);
				this.game.ctsMsg.timer = null;
				this.ctsCapturedMsg();
			}
		},

	bestStreakUpdate() {
		this.$refs.shellStreakCap.classList.add('streak-blow-out');

		if (this.game.streakMsg.timer != null) {
			clearTimeout(this.game.streakMsg.timer);
			this.game.streakMsg.timer = null;
		}

		this.game.streakMsg.timer = setTimeout(() => {
			this.$refs.shellStreakCap.classList.remove('streak-blow-out');
			this.game.streakMsg.timer = null;
		}, 300);
	},
	ingameNotification() {
		const { ingameNotification } = this.game;
		const { item } = ingameNotification;

		// Types 0, 1 are for kill/death messages
		// Simplify message setting based on type

		//	HardBoiled: 1,
		// EggBreaker: 2,
		// Restock: 3,
		// OverHeal: 4,
		// MiniEgg: 5,
		// DoubleEggs: 6
		if (item.type === 0 || item.type === 1) {
			const messages = ['ui_game_youkilled', 'ui_game_killedby'];
			const styles = ['killed', 'died'];
			item.msg = this.loc[messages[item.type]].format(item.msg);
			item.style = styles[item.type];
		} else {
			if (item.streakType) {
				// const ksLocs = ['', 'ks_hardboiled', 'ks_egg_breaker', 'ks_restock', 'ks_overheal', 'ks_double_eggs', 'ks_miniegg'];
				const ksLocs = {
					[ShellStreak.HardBoiled]: 'ks_hardboiled',
					[ShellStreak.EggBreaker]: 'ks_egg_breaker',
					[ShellStreak.Restock]: 'ks_restock',
					[ShellStreak.OverHeal]: 'ks_overheal',
					[ShellStreak.DoubleEggs]: 'ks_double_eggs',
					[ShellStreak.MiniEgg]: 'ks_miniegg'
				};
				if (ksLocs) {
					item.msg = this.loc[ksLocs[item.streakType]];
				} else {
					return;
				}
			}
		}
		// Attempt to show the notification
		this.attemptToShowNotification();
		
	},

	attemptToShowNotification() {
		const { ingameNotification } = this.game;
		const { showing } = ingameNotification;

		this.applyNotificationEffects();
			// Set showing to true to start or continue display
		ingameNotification.showing = true;

		// Clear any existing timer and set a new one
		clearTimeout(ingameNotification.timer);

		ingameNotification.timer = setTimeout(() => {
			this.clearNotificationEffects();
			ingameNotification.showing = false;
		}, 3000);
	},

	applyNotificationEffects() {
		this.$refs.killMsg.classList.add('streak-blow-out');

		// Clear any previous short-duration effects
		clearTimeout(this.game.ingameNotification.multiTimer);

		this.game.ingameNotification.multiTimer = setTimeout(() => {
			this.$refs.killMsg.classList.remove('streak-blow-out');
		}, 200);
	},

	clearNotificationEffects() {
		// Remove visual effects
		this.$refs.killMsg.classList.remove('streak-blow-out');
		clearTimeout(this.game.ingameNotification.multiTimer);
		this.game.ingameNotification.multiTimer = null;
	},		

	},

    computed: {
        isRespawning: function () {
            return this.game.respawnTime > 0;
        },

        isTeamGame: function () {
            // Would be better to use the same enum as the client game code
            return this.game.gameType !== 0;
        },

        teamColorCss: function () {
            return this.game.team === this.ui.team.blue ? 'blueTeam btn_red bevel_red' : 'redTeam btn_blue bevel_blue';
        },

        teamName: function () {
            return this.game.team === this.ui.team.blue ? this.loc.p_pause_joinred : this.loc.p_pause_joinblue;
        },

        newTeamColorCss: function () {
            return this.game.team === this.ui.team.blue ? 'redTeam btn_red' : 'blueTeam btn_blue';
        },

        newTeamName: function () {
            return this.game.team === this.ui.team.blue ? this.loc.team_red : this.loc.team_blue;
        },

        muteButtonLabel: function () {
            return this.playerActionsPopup.muted ? this.loc.ui_game_playeractions_unmute : this.loc.ui_game_playeractions_mute;
        },
        showIngameWidget() {
            if (!this.game.isPaused && this.songChanged) {
                this.songHasChanged();
                return true;
            }
            return false;
        },
        showMusicWidget() {
            return this.showScreen === 2;
        },
		isEggStoreSaleItem() {
            return this.eggStoreItems.some( item => item['salePrice'] !== '' && this.ui.showCornerButtons);
        },
        upgradeBadgeUrl() {
            return 'img/vip-club/vip-club-popup-emblem.webp';
        },
        playerSocial() {
            return SOCIALMEDIA[this.playerActionsPopup.social.id];
        },
		chwShowVideoIcon() {
			return this.chw.winnerCounter > 0 && !this.chw.limitReached && this.chw.ready;
		},
		progressMsg() {
			if (this.chw.adBlockDetect) {
				return 'Please turn off ad blocker';
			}
			if (this.isChicknWinnerError) {
				return this.loc.chw_error_text;
			}
			if (this.chw.ready && !this.chw.limitReached) {
				return this.chw.winnerCounter > 0 ? this.loc.chw_cooldown_msg : this.loc.chw_ready_msg;
			}
			if (!this.chw.ready && !this.chw.limitReached) {
				return this.loc.chw_time_until;
			}
			if (this.chw.limitReached) {
				return this.loc.chw_daily_limit_msg;
			}
		},
		progressBarWrapClass() {
			if (this.isChicknWinnerError) {
				return 'chw-progress-bar-wrap-error';
			}

			if (this.chw.ready && !this.chw.limitReached) {
				return 'chw-progress-bar-wrap-complete';
			}
		},
		playAdText() {
			return vueApp.getChwPlayAdText();
		},
		chwShowCountdown() {
			if (this.chw.limitReached || this.isChicknWinnerError) {
				return 'hideme';
			} else {
				if (this.chw.ready) {
					return 'hideme';
				} else {
					return 'display-inline';
				}
			}
		},
		chwChickSrc() {
			if (this.chw.limitReached || this.isChicknWinnerError) {
					return this.chw.imgs.limit;
				} else {
					if (!this.chw.ready) {
						return this.chw.imgs.sleep;
					} else {
						return this.chw.imgs.speak;
					}
				}
		},

		playBtnColor() {
			if (!this.delayTheCracking && !this.isRespawning || this.delayTheCracking && this.isRespawning) {
				return 'btn_red bevel_red';
			} else {
				return 'ss_button btn_green bevel_green';
			}
		},

		playBtnText() {
			if (!this.delayTheCracking && !this.isRespawning) {
				return this.loc.ui_game_get_ready;
			} else if (this.delayTheCracking && this.isRespawning) {
				if (this.game.respawnTime > 5) {
					return this.game.respawnTime - 5;
				} else {
					return this.game.respawnTime
				}
			} else {
				return this.loc.p_pause_play;
			}
		},

		playBtnAdBlockerText() {
			if (this.delayTheCracking && this.isRespawning && extern.adBlocker && this.game.respawnTime <= 5 && !extern.productBlockAds && !this.isPoki) {
				return 'Ad block delay!';
			}
		},
		classGameType() {
			if (this.game.gameType === 0) {
				return 'pause-screen-free-for-all'
			}
		},
		pauseScreenWrapGrid() {
			if (!this.isSubscriber) {
				return 'pause-screen-wrapper-no-vip';
			} else {
				return 'pause-screen-wrapper-is-vip'
			}
		},
		pauseScreenStateClass() {
			if (this.game.isPaused) {
				return `is-paused ${this.game.openPopupId}`
			}
		},
		chatEnabled() {
			return this.settingsUi.togglers.misc[this.settingsUi.togglers.misc.findIndex(item => item.id === "enableChat")].value
		},
		chwProgress() {
			return this.chw.progress + '%';
		},
		isReportFilled () {
			return this.reportPlayerPopup.checked.some(checked => checked === true);
		},
		serverLoc() {
			return this.loc['server_' + this.currentRegionId];
		},
		spectateControls () {
			let key = this.settingsUi.controls.keyboard.spectate[this.settingsUi.controls.keyboard.spectate.findIndex(item => item.id === "toggle_freecam")].value;
			return this.loc['ui_game_spectate_controls'].format(key);
		},
		canChangeTeams () {
			return !(extern.GameOptions.value.flags & extern.GameFlags.noTeamChange);
		},
		optionsButtonClass () {
			if (this.gameOptionsPopup.usingDefaults) {
				return 'btn_blue bevel_blue';
			}

			return 'btn_yolk bevel_yolk';
		},
		wakeTheChw() {
			return this.loc.chw_wake.format(200 * (this.chw.resets + 1));
		}
    },

    watch: {
        isPokiGameLoad(value) {
            this.pokiTimers(value, this.videoRewardTimers.initial);
            // this.pokiTimers(value, 300);
        },
        isPokiNewRewardTimer(value) {
            this.pokiTimers(value, this.videoRewardTimers.primary);
            // this.pokiTimers(value, 300);
        },
        kname(val) {
            this.killedByMessage = this.loc['ui_game_killedby'].format(val);
        },
        kdname(val) {
            this.killedMessage = this.loc['ui_game_youkilled'].format(val);
        },
		announcementMessage(val) {
			if (val) {
				this.announcementMsg();
			} else {
				this.announcementMsgReset();
			}
		}
    }
};
</script><script id="photoBooth-screen-template" type="text/x-template">
	<div data-html2canvas-ignore>
		<div class="box_relative margins_lg screens-menu" :class="{'phb-active-bg' : bgIdx}">
			<div v-show="uiActive">
				<h3 class="pb-title text-center text_white display-grid grid-auto-flow-column justify-content-center gap-sm text-shadow-black-40"><img class="pb-title-img" src="img/photo-booth/ico_shelfieStars.svg" />Shellfie<br /> Booth <img class="pb-title-img pb-title-img-flip"src="img/photo-booth/ico_shelfieStars.svg" /></h3>
				<section id="photoBooth-map" class="ss_marginbottom photo-booth-map-section">
					<ss-button-dropdown class="btn-1 fullwidth" :loc="loc" :loc-txt="mapTxt" :list-items="bgData" :selected-item="bgIdx" menuPos="right" @onListItemClick="onChangeMap"></ss-button-dropdown>
				</section>
				<section id="photoBooth-egg-sizes" class="ss_marginbottom">
					<ss-button-dropdown class="btn-1 fullwidth" :loc="loc" :loc-txt="eggSizeTxt" :list-items="egg.sizes" :selected-item="eggSize" menuPos="right" @onListItemClick="onChangeEggSize" :loc-list="true"></ss-button-dropdown>
				</section>
				<!-- <section id="photoBooth-vignette" class="ph-egg-hide pb-vignette-setting btn_big common-box-shadow btn_game_mode bg_blue6 text-left border-blue5 ss_marginbottom display-grid align-items-center">
					<h3 class="ss-dropdown-select text_blue3 display-grid grid-column-2-1 fullwidth align-items-center">{{ loc.screen_photo_booth_vignette }} Vignette<label class="ss_checkbox label justify-self-end"> <span class="hideme">{{ loc.screen_photo_booth_vignette }}</span> <input type="checkbox" :checked="vignette" @change="onVignetteChange(true)"> <span class="checkmark"></span></label></h3>
				</section> -->
				<section id="photoBooth-egg-hide-item" class="ph-egg-hide btn_big common-box-shadow btn_game_mode bg_blue6 text-left border-blue5 ss_marginbottom">
					<h3 class="ss-dropdown-select text_blue3">{{ loc.screen_photo_booth_show_hide }}</h3>
					<div class="display-grid grid-column-3-eq justify-items-center align-items-center center_h">
						<button v-for="(item, idx) in egg.items" :id="item.id" :key="item.value" class="ico_itemtype clickme roundme_sm f_row align-items-center" @click="hideEggItem(item.value, idx)" :class="{'selected' : !item.hidden}">
							<svg>
								<use :xlink:href="item.icon"></use>
							</svg>
						</button>
					</div>
				</section>
				<section id="photoBooth-instructions" class="ph-egg-hide btn_big common-box-shadow btn_game_mode bg_blue6 text-left border-blue5 ss_marginbottom">
					<h3 class="ss-dropdown-select text_blue3">{{ loc.screen_photo_booth_instructions }}</h3>
					<ul class="font-nunito text_blue5">
						<li><strong>{{ loc.screen_photo_booth_point_one }}</strong></li>
						<li><strong>{{ loc.screen_photo_booth_point_two }}</strong></li>
					</ul>
				</section>
			</div>
			<div class="fullwidth ss_marginbottom display-flex">
				<button class="ss_button btn_yolk bevel_yolk box_relative fullwidth text-uppercase" @click="screenGrabStartProcess"><i class="fas fa-camera"></i> {{ loc.screen_photo_booth_screenshot }}</button>
			</div>
			<div ref="photoBoothDisplayAd" class="hideme f_col align-items-center"></div>
		</div>
		<small-popup id="screenshotPopup" ref="screenshotPopup" @popup-confirm="screenGabDownload">
			<template slot="header">{{ loc.screen_photo_booth_screenshot2 }}</template>
			<template slot="content">
				<div ref="grabImage" class="photo-booth-screen-grab"></div>
			</template>
			<template slot="cancel">{{ loc.close }}</template>
			<template slot="confirm">{{ loc.screen_photo_booth_download }}</template>
		</small-popup>

	</div>
</script>


<script>
const CompPhotoboothUi = {
    template: '#photoBooth-screen-template',
	props: ['loc', 'playerName', 'itemTypeChange'],
	data: function () {
		return {
			eggSize: 0,
			bgIdx: 0,
			uiActive: true,
			showBtn : true,
			screenshotImg: '',
			// vignette: false,
			// vignetteUpdated: false,
			egg: {
				sizes: [
					{ id: 'egg-size-normal', name: 'screen_photo_booth_size_normal', value: 0 },
					{ id: 'egg-size-medium', name: 'screen_photo_booth_size_medium', value: 1 },
					{ id: 'egg-size-large', name: 'screen_photo_booth_size_large', value: 2 }
				],
				items: [
					{ id: 'item-type-3', name: 'Primary', value: 3,  hidden: false, icon: ItemIcons.Primary},
					{ id: 'item-type-4', name: 'Secondary', value: 4,  hidden: false, icon: ItemIcons.Secondary},
					{ id: 'item-type-1', name: 'Hat', value: 1, hidden: false, icon: ItemIcons.Hat},
					{ id: 'item-type-2', name: 'Stamp', value: 2,  hidden: false, icon: ItemIcons.Stamp},
					{ id: 'item-type-6', name: 'Grenade', value: 6, hidden: false, icon: ItemIcons.Grenade},
					{ id: 'item-type-7', name: 'Melee', value: 7,  hidden: false, icon: ItemIcons.Melee}
				],
			},
			background: {
				map: {
					names: ['none', 'aqueduct', 'chickenitzaeggsmas', 'backstage', 'backstageeggsmas', 'bedrock', 'castle', 'castletwo', 'catacombs', 'dirt', 'downfall', 'enchanted', 'exposure', 'jinx', 'mansion', 'outerreacheggsmas', 'quarters', 'raceway', 'rats2', 'scales', 'skyscratcher', 'spacefactory', 'teggtris', 'timetwist', 'twotowers', 'wimble', 'quarry'],
				},
				color: {
					none: '',
					colorRed: 'bg_red',
					colorBlue: 'bg_blue3',
					colorGreen: 'bg_green',
				}
			},
		}
    },
    methods: {
		onChangeEggSize(size) {
			if (size === this.eggSize) return;
			this.eggSize = size;
			extern.photoBooth.eggDollSize(this.eggSize);
			BAWK.play('ui_click');
		},
		onChangeMap(idx) {
			if (idx === this.bgIdx) return;
			this.bgIdx = idx;
			if (this.bgData[this.bgIdx].bgColor) {
				this.$emit('bg-change-image', this.bgData[0].url);
				this.$emit('bg-change-color', this.background.color[this.bgData[this.bgIdx].url]);
			} else {
				this.$emit('bg-change-color', this.background.color.none);
				this.$emit('bg-change-image', this.bgData[this.bgIdx].url);
			}
			BAWK.play('ui_click');
		},
		hideEggItem(item, idx, hideAudio) {

			if (this.egg.items[idx].hidden) {
				this.egg.items[idx].hidden = false;
				this.$nextTick().then(()=> {
					vueApp.$refs.equipScreen.switchItemType(this.egg.items[idx].value);
				})

			} else {
				this.egg.items[idx].hidden = true;
			}

			extern.photoBooth.hideItem(this.egg.items[idx]);
			if (!hideAudio || hideAudio === undefined) {
				BAWK.play('ui_click');
			}
		},
		onShowOuterUi() {
			this.showOuterUi(this.uiActive ? false : true);
			BAWK.play('ui_click');
		},
		showOuterUi(val) {
			this.uiActive = val;
			this.$emit('hide-ui', this.uiActive);
		},
		open() {
			// this.onVignetteChange();
			// randomize background
			this.onChangeMap(Math.floor(Math.random()*this.background.map.names.length));
		},
		close() {
			// this.vignette = false;
			this.eggSize = 0;
			this.bgIdx = 0;
			this.uiActive = true;
			this.showBtn = true;
			this.screenshotLoaded = false;
			this.egg.items.forEach((el, idx) => this.egg.items[idx].hidden = false);
			// this.updateVignette(this.vignette);
			this.$emit('bg-change-image', this.background.map.names[this.bgIdx].url);
			this.$emit('bg-change-color', this.background.color.none);
		},
		screenGrabStartProcess() {
			BAWK.play('ui_click');
			// if (!this.bgIdx) {
			// 	this.updateVignette(false);
			// 	this.vignetteUpdated = true;
			// }
			extern.photoBooth.getScreenshot(!this.bgIdx);

			// this.$nextTick().then(() => {
			// 	extern.photoBooth.getScreenshot(!this.bgIdx);
			// });
		},
		screenGrabDone(canvas) {
			if (!hasValue(canvas)) {
				this.showOuterUi(true);
				return;
			}

			// if (this.vignetteUpdated) {
			// 	this.updateVignette(true);
			// 	this.vignetteUpdated = false;
			// }
		
			if (this.screenshotImg) {
				if (this.$refs.grabImage.hasChildNodes()) {
					this.$refs.grabImage.removeChild(this.$refs.grabImage.children[0]);
					this.screenshotImg = null;
				}
			}
			this.screenshotImg = new Image();
			this.screenshotImg.src = canvas;
			// this.$refs.grabCanvas.appendChild(canvas);
			this.$refs.grabImage.appendChild(this.screenshotImg);
			this.showOuterUi(true);

			// extern.photoBooth.screenGrab(false, this.$refs.screenshotPopup.show());
			this.$refs.screenshotPopup.show()
			this.gaSendStuff();

		},
		gaSendStuff() {
			let items = extern.getEquippedItems();
			Object.keys(items).forEach((key) => {
				let idx = this.egg.items.findIndex(el => el.value === Number(key));
				ga('send', 'event', 'photo-booth', getKeyByValue(ItemType, Number(key)), !hasValue(items[key]) || this.egg.items[idx].hidden ? 'hidden' : `${items[key].name}` );
			});
			ga('send', 'event', 'photo-booth', 'background', this.bgData[this.bgIdx].url);
		},
		screenGrabStart() {
			extern.photoBooth.screenGrabRequested = true;
			extern.photoBooth.screenGrab();
		},
		screenGabDownload() {
			if (this.screenshotImg) {
				this.screenshotImg.crossOrigin = 'anonymous';
				const link = document.createElement('a');
				link.download = `Shellshock-io-${this.playerName}.png`;

				link.href = this.screenshotImg.src;
				link.click();
				ga('send', 'event', 'photo-booth', 'click', 'download');

			}
		},
		updateTypeVisibility(val) {
			let idx = this.egg.items.findIndex(el => el.value === val);
			if (this.egg.items[idx].hidden) this.egg.items[idx].hidden = false;
		},
    },
	computed: {
		eggSizeTxt() {
			return {
				title: this.loc.screen_photo_booth_size_title,
				subTitle: this.loc[this.egg.sizes[this.eggSize].name],
			}
		},
		mapTxt() {
			return {
				title: this.loc.screen_photo_booth_background,
				subTitle: this.bgData[this.bgIdx].name,
			}
		},
		uiTxt() {
			return this.uiActive ? this.loc.screen_photo_booth_hide_ui : this.loc.screen_photo_booth_show_ui;
		},
		bgData() {
			const maps = [];
			this.background.map.names.forEach((el, idx) => maps.push({ name: this.loc[`screen_photo_booth_map_${el}`], value: idx, url: el, bgColor: el.includes('color') ? true : false}));
			return maps;
		}
	},
	watch: {

	}
};
</script>
<script id="vip-club-template" type="text/x-template">
    <div class="vip-club centered">
		<img v-lazyload :data-src="ui.lazyImages.vipPopupBg" class="lazy-load vip-club-background centered" alt="VIP background image">

        <div class="vip-club-log-content--outer roundme_sm display-grid grid-column-1-2 grid-gap-space-lg box_relative">
			<header class="grid-span-2-start-1">
				<!-- <h2><span class="text-orange">V</span>ery <span class="text-orange">I</span>mportant <span class="text-orange">P</span>oultry</h2> -->
				<span class="sr-only">Very Important Poultry</span>
				<img v-lazyload :data-src="ui.lazyImages.vipImportant" class="lazy-load vip-club-water-mark display-block center_h" alt="Very Important Poultry text image">

			</header>
            <div class="vip-club--logo display-grid align-content-space-between">
				<img v-lazyload :data-src="ui.lazyImages.vipEmblem" class="lazy-load center_h" alt="Shell Shockers VIP">
				<button v-on:click="openVipPopup" class="display-block ss_button btn_sm bevel_blue btn_blue center_h">{{loc.faq}}</button>
            </div>
            <div class="vip-club--content">
                <div class="subs-info">
                    <ul class="display-grid align-content-space-between">
                        <li class="display-grid align-items-start"><img class="vip-club-star" src="img/vip-club/vip-club-popup-bullet-point-star.webp" alt="star-list-img">{{loc.p_chicken_goldfeature1}}</li>
                        <li class="display-grid align-items-start"><img class="vip-club-star" src="img/vip-club/vip-club-popup-bullet-point-star.webp" alt="star-list-img"> <span v-html="loc.p_chicken_goldfeature3"></span></li>
                        <li class="display-grid align-items-start"><img class="vip-club-star" src="img/vip-club/vip-club-popup-bullet-point-star.webp" alt="star-list-img"><span v-html="eggsPerKill"></span></li>
                        <li class="display-grid align-items-start"><img class="vip-club-star" src="img/vip-club/vip-club-popup-bullet-point-star.webp" alt="star-list-img"> {{loc.s_popup_feature_premium_items}}</li>
						<li class="display-grid align-items-start"><img class="vip-club-star" src="img/vip-club/vip-club-popup-bullet-point-star.webp" alt="star-list-img"> {{loc.s_popup_feature_premium_stamp_pos}}</li>
						<li class="display-grid align-items-start"><img class="vip-club-star" src="img/vip-club/vip-club-popup-bullet-point-star.webp" alt="star-list-img"> {{loc.s_popup_and_more}}</li>
                    </ul>
                </div>
            </div>
        </div>
		<h3 class="box_relative text-center text_white ss_margintop_micro ss_marginbottom_micro text-shadow-black-40 z-index-1">{{ membershipTxt }}</h3>
        <div class="subscription-plans box_relative" :class="subStyle">
            <div class="vip-club-items--outer display-grid" :class="[hasPlan ? 'grid-column-1-eq justify-items-center' : 'grid-column-3-eq']">
                <sub-item v-for="sub in getSubs" :key="sub.sku" :item="sub" :loc="loc" :upgrade-name="upgradeName" :is-subscriber="isSubscriber" :is-upgraded="isUpgraded" :account-set="accountSettled"></sub-item>
            </div>
            <div v-if="hasPlan" class="manage-subscription-wrapper">
                <div v-if="hasPlan" class="plan-details text-center vip-club-log-content--outer roundme_sm">
                    <h5>{{loc.sRenewalDate}}:</h5>
                        <p v-if="expireDate" class="plan-expiry">{{ expireDate }}</p>
                        <p class="manage-details" v-html="manageInfo"></p>
                    	<button class="display-block ss_button btn_sm bevel_blue btn_blue center_h" v-on:click="onManageClick">{{loc.sManageBtn}}</button>
                </div>
            </div>
        </div>
		<img v-lazyload :data-src="ui.lazyImages.vipPayment" class="lazy-load payment-options display-block center_h box_relative ss_margintop_micro" alt="Payment options: Visa, Mastercard PayPay, Amazon Pay, Google Pay">
		<p class="ss_margintop_micro box_relative text-center font-size-lg font-800">{{loc.s_popup_and_more}}</p>

    </div>
	<!-- end .vip-club -->
</script>

<template id="comp-sub-item">
    <div v-if="isActive" class="vip-item text-center box_relative center_h" :class="vipStyle">
        <div class="vip-item--inner centered">
            <div class="subscription-details">
                <header>
                    <h3 class="text_white">{{loc[name]}}</h3>
                </header>
                <p class="price-tag roundme_sm" v-html="priceTag"></p>
				<p class="value nospace font-size-md">{{valueTxt}}</p>
                <button v-if="!hasSub" class="ss_button btn_sm btn_blue bevel_blue" v-on:click="subClick">
                    {{loc[buyBtnText]}}
                </button>
            </div>
        </div>
		<div v-if="flagText" class="vip-banner" :class="flagText">
            <span>{{loc[flagText]}}</span>
        </div>
		<img v-lazyload :data-src="img" class="lazy-load" aria-hidden="true" />
    </div>
</template>
<script>
    const comp_sub_item = {
        template: '#comp-sub-item',
        props: ['loc', 'item', 'upgradeName', 'isUpgraded', 'isSubscriber'],
        data() {
            return {
                isCurrentSub: false,
                hasSub: false,
                hasUpgrade: false,
                locName: '',
				numberWords: {
					'1': 'one',
					'12': 'twelve',
					'3': 'three',
				}
            };
        },
        methods: {
            subClick() {

                if (this.$parent.$el.id === 'shell-subscriptions') {
                    this.$parent.$parent.hide();
                } else {
                    this.$parent.hide();
                }

                BAWK.play('ui_click');

                if (this.hasSub) {
                    extern.buyProductForMoney();
                } else {
                    extern.buyProductForMoney(this.item.sku, true);
                    ga('send', 'event', 'subscriptions', 'click', this.locName);
                }
            }
        },
        computed: {
            nameLowerCaseHyphens() {
                this.locName =  this.item.name.replace(' ', '-').toLowerCase().replace(' ', '-');
                return this.locName;
            },
			vipStyle() {
				return this.nameLowerCaseHyphens.replace(/\d/g, match => this.numberWords[match]);
			},
            name() {
                return `s-${this.locName}-title`;
            },
            img() {
                return `img/vip-club/vip-club-popup-item-${this.locName}-bg.webp`;
            },
            priceTag() {
                let price = this.item.salePrice ? this.item.salePrice : this.item.price,
                    priceWcents = `${(price / 100).toFixed(2)}`,
                    thePrice = priceWcents.split('.');
                return `$${thePrice[0]}<span class="price-tag--cents">.${thePrice[1]}</span>`;
            },
            buyBtnText() {
                if (this.isCurrentSub && this.hasUpgrade) {
                    return 'sManageBtn';
                }
                return 's_btn_txt_subscribe';
            },
            isActive() {
                if (this.isCurrentSub && this.hasUpgrade) {
                    return true
                } else if (this.hasSub && this.hasUpgrade) {
                    return false
                } else {
                    return true
                };
            },
            flagText() {
                if (this.isCurrentSub && this.hasUpgrade) return 'p_egg_shop_purchased';
                return this.item.flagText;
            },
			valueTxt() {
				const amt = {
					25: 10,
					26: 30,
					27: 120,
				}

				return this.loc['s-membership-value'].format(amt[this.item.id]);
			}
        },
        watch: {
            upgradeName(val) {
                
            },
            isUpgraded(val) {
                this.hasUpgrade = val;
                this.hasSub = this.isSubscriber && this.hasUpgrade;
                this.isCurrentSub = this.upgradeName === this.item.name && this.hasUpgrade;
            }
        }
    };
</script>
<script>
var compVipClubTemplate = {
    template: '#vip-club-template',
    components: {
        'sub-item': comp_sub_item,
    },
    data() {
        return vueData;
    },
    props: ['subs'],
    
    methods: {
        onManageClick() {
            if (this.$parent.$el.id === 'shell-subscriptions') {
                this.$parent.$parent.hide();
            } else {
                this.$parent.hide();
            }
            extern.buyProductForMoney();
        },
        openVipPopup() {
            if (this.$parent.$el.id === 'shell-subscriptions') {
                this.$parent.$parent.hide();
            } else {
                this.$parent.hide();
            }
            BAWK.play('ui_click');
            vueApp.showVipPopup();
        }
    },
    computed: {
        hasPlan() {
            return this.isSubscriber && this.isUpgraded;
        },
        expireDate() {
            if (this.hasPlan) {
                return new Date(extern.account.upgradeExpiryDate).toUTCString();
            }
            return;
        },
        planName() {
            if (this.hasPlan) {
                return 's-' + this.upgradeName.replace(' ', '-').toLowerCase().replace(' ', '-') + '-title';
            }
            return;
        },
        manageInfo() {
            return this.loc.sManageInfo;
        },
		membershipTxt() {
			return this.hasPlan ? 'Membership' : 'Membership Options';
		},
		subStyle() {
			return this.hasPlan ? 'display-grid grid-column-1-2 vip-club-has-plan' : '';
		},

		eggsPerKill() {
			return this.loc.p_chicken_goldfeature2.format('<img src="img/svg/ico_goldenEgg.svg" />');
		},
		getSubs() {
			if (this.hasPlan) {
				if (this.subs && this.subs.length > 0) {
					return this.subs.filter(i => i.id === extern.account.upgradeProductId);
				}
			} else {
				return this.subs;
			}
		}
    }
};
</script><script id="give-stuff-popup" type="text/x-template">
   <!-- Popup: Give Stuff -->
   <!-- <large-popup id="giveStuffPopup" ref="giveStuffPopup" :popup-model="giveStuffPopup" @popup-closed="onSharedPopupClosed" :class="giveStuffPopup.type"> -->
   <large-popup id="giveStuffPopup" ref="giveStuffPopup" :popup-model="giveStuffPopup" :class="giveStuffPopup.type" @popup-closed="onGiveStuffPopupClosed">
        <template slot="content">
			<div id="giveStuffPopup-content" class="giveStuffPopup-content" :class="{'fullwidth' : giveStuffPopup.type === 'twitchDrops'}">
				<div v-if="giveStuffPopup.type === 'vip'" id="give-stuff-icon" class="give-stuff-icon">
					<img v-lazyload :data-src="imgs.vipEmblem" class="lazy-load" alt="Shell Shockers VIP">
				</div>

				<h3 v-if="giveStuffPopup.type !== 'twitchDrops'" :class="{'popup-title-vip' : giveStuffPopup.type === 'vip'}" id="popup_title" class="roundme_sm text-center text_white" v-html="popupTitle">
				</h3>

				<h2 v-if="giveStuffPopup.type === 'twitchDrops'" id="popup_title" class="roundme_sm text-center title-shadow text-twitch-yellow">
					{{ loc[giveStuffPopup.titleLoc] }}
				</h2>

				<p v-if="giveStuffPopup.type === 'twitchDrops'" class="text-center">{{ loc.give_stuff_twitch_sub_desc }}</p>
				<div v-show="(giveStuffPopup.eggs)" class="f_row">
					<div class="egg-give-stuff">
						<img v-lazyload :data-src="imgs.eggPackSm" class="lazy-load" />
						<h2>+ <img v-lazyload :data-src="imgs.goldenEgg" class="lazy-load vertical-align-middle width_1" />{{giveStuffPopup.eggs}}</h2>
					</div>
				</div>
				<div v-show="giveStuffPopup.rickroll" class="f_row">
					<img v-lazyload :data-src="imgs.rickRoll" class="lazy-load" style="margin-bottom: 1em; height: 25em;" alt="Rick Roll!" />

				</div>
				<div v-show="giveStuffPopup.eggOrg" class="f_row">
					<img v-lazyload :data-src="imgs.eggOrgGiveStuff" class="lazy-load" style="margin-bottom: 1em;" alt="Egg Org" />

				</div>
				<div v-show="(giveStuffPopup.items && giveStuffPopup.items.length > 0)" class="items-container f_row gap-1 " :class="{'popup-items-vip' : giveStuffPopup.type === 'vip'}">
					<item v-for="i in giveStuffPopup.items" :loc="loc" :item="i" :key="i.id" :isSelected="false" :show-item-only="true"></item>
				</div>
				<p v-if="giveStuffPopup.type === 'twitchDrops'"></p>
			</div>
            <footer :class="{'text-center' : giveStuffPopup.type === 'twitchDrops'}">
				<!-- <p v-if="giveStuffPopup.type === 'twitchDrops'" class="text-center">{{ loc.give_stuff_twitch_footer_desc }}</p> -->
                <button class="ss_button width_xs text-center" :class="giveStuffPopup.type === 'twitchDrops' ? 'twitch-btn twitch-btn-purple' : 'btn_green bevel_green'" @click="onGiveStuffComplete">{{ loc.ok }}</button>
				<button v-if="giveStuffPopup.type === 'twitchDrops'"class="ss_button twitch-btn twitch-btn-pink width_xs text-center" @click="onClickTwitchDropsMore">{{ loc.eq_buy_stuff }}</button>
            </footer>

        </template>
        <template slot="confirm">{{ loc.confirm }}</template>
    </large-popup>
</script>


<script>
const GIVESTUFFPOPUP = {
	template: '#give-stuff-popup',
	components: {
		'item': comp_item,
	},
	props: ['loc', 'giveStuffPopup', 'imgs'],

	data: function () {
		return {
			languageCode: this.selectedLanguageCode,
			eggBalance: 0,
			vueData,
		}
	},
	methods: {
		onGiveStuffComplete: function () {
			this.giveStuffPopup.eggOrg = false;
			this.giveStuffPopup.rickroll = false;
			vueApp.onGiveStuffComplete();
        },
		onClickTwitchDropsMore() {
			window.open(dynamicContentPrefix + 'twitch');
			this.onGiveStuffComplete();
		},
		onGiveStuffPopupClosed() {
			vueApp.onGiveStuffPopupClosed();
		}
	},
	computed: {
		popupTitle() {
			if (this.giveStuffPopup.type) {
				return this.loc[this.giveStuffPopup.titleLoc];
			} else {
				return this.loc.reward_title;
			}
		},
	}
};
</script>
<script id="game-options-popup" type="text/x-template">
	<!-- Popup: Private Game Options -->
    <large-popup id="gameOptionsPopup" ref="gameOptionsPopup" :popup-model="gameOptionsPopup" @popup-x="onCancel">
        <template slot="content">
			<h1 class="text_white margin-0">{{ loc.game_options_title }}</h1>
			<b style="margin-block: 0.5em">{{ loc.p_sharelink_text }}</b>

			<div class="nowrap">
				<i :class="icon.invite" style="size: 1em; zoom: 1.5; color: var(--ss-blue5)"></i>
				<input ref="shareLinkUrl" type="text" style="flex: auto; width: 29em" class="ss_field" v-model="game.shareLinkPopup.url" @focus="$event.target.select()">
				<button class="ss_button btn_blue bevel_blue btn_md" @click="onShareLinkCopy">{{ loc.game_options_copyShareLink }}</button>
			</div>

			<section class="ss_section" style="width: 40em;">
				<div class="f_center f_row">
					<h3 class="text_darkblue margin-0">{{ loc.game_options_serverSettings }}</h3>
				</div>
				<div class="f_center f_row">
                    <div class="f_col ss_marginright_lg">
						<div v-for="t in gameOptionsPopup.togglers" class="nowrap">
							<label class="ss_checkbox label">{{ loc[t.locKey] }}
								<input :disabled="!extern.isGameOwner" :id="t.id" type="checkbox" v-model="t.value" @input="checkboxChange">
								<span class="checkmark ss_marginbottom_lg"></span>
							</label>
						</div>
					</div>

					<div class="f_col">
						<div v-for="t in gameOptionsPopup.adjusters" class="nowrap">
							<settings-adjuster :disabled="!extern.isGameOwner" small-header="true" :loc="loc" :loc-key="t.locKey" :control-id="t.id" :control-value="t.value" :min="t.min" :max="t.max" :step="t.step" :precision="t.precision" :multiplier="t.multiplier" labelSuffix="x" @setting-adjusted="onSettingAdjusted"></settings-adjuster>
						</div>
					</div>
				</div>
			</section>
			<section class="ss_section" style="width: 40em;">
				<div class="f_center f_row">
					<h3 class="text_darkblue margin-0">{{ loc.game_options_weaponsHeader }}</h3>
				</div>
				<weapon-select-panel id="weapon_select" :loc="loc" :disabler="true" :hide-desc="true" :account-settled="accountSettled" :play-clicked="false" :current-class="classIdx" @weapon-toggled="toggleWeaponClass" :current-screen="showScreen" :screens="screens"></weapon-select-panel>
			</section>
			<div class="ss_button_row">
				<button v-if="extern.isGameOwner" class="ss_button btn_red bevel_red btn_md" :disabled="gameOptionsPopup.resetClicked" @click="resetGame">{{ loc.game_options_reset_button }}</button>
				<button v-if="extern.isGameOwner" class="ss_button btn_yolk bevel_yolk btn_md" @click="onDefaults">{{ loc.game_options_defaults_button }}</button>
				<button v-if="extern.isGameOwner" class="ss_button btn_green bevel_green btn_lg" @click="onApply">{{ loc.game_options_apply_button }}</button>
				<button v-if="!extern.isGameOwner" class="ss_button btn_green bevel_green btn_lg" @click="onOkClicked">{{ loc.ok }}</button>
			</div>
        </template>
    </large-popup>
</script>


<script>
var comp_game_options_popup = {
    template: '#game-options-popup',
	components: {
		'settings-adjuster': comp_settings_adjuster,
		'weapon-select-panel': comp_weapon_select_panel,
		//'settings-toggler': comp_settings_toggler
	},
	data: function () {
		return vueData;
    },
    methods: {
		onShareLinkCopy () {
            extern.copyFriendCode(this.$refs.shareLinkUrl);
        },
		onDefaults () {
			this.gameOptionsPopup.options = deepClone(extern.GameOptions.getDefaults());
			this.gameOptionsPopup.changesMade = true;
			this.init();
			BAWK.play('ui_onchange');
		},
		onShow () {
			this.gameOptionsPopup.resetClicked = false;
			this.gameOptionsPopup.options = deepClone(extern.GameOptions.value);
			this.init();
			BAWK.play('ui_popupopen');
		},
		onApply () {

			if (this.gameOptionsPopup.changesMade) {
				this.gameOptionsPopup.options.flags = 0;

				this.gameOptionsPopup.togglers.forEach(t => {
					if (t.value === true) {
						this.gameOptionsPopup.options.flags |= extern.GameFlags[t.id];
					}
				});

				this.gameOptionsPopup.adjusters.forEach(t => {
					this.gameOptionsPopup.options[t.id] = parseFloat(t.value);
				});

				extern.GameOptions.value = deepClone(this.gameOptionsPopup.options);
				this.gameOptionsPopup.usingDefaults = extern.GameOptions.usingDefaults();
				
				if (extern.inGame) {
					extern.sendGameOptions();
					extern.sendGameOptionsMetrics();
				}
				vueData.selectedWeaponDisabled = extern.GameOptions.isSelectedWeaponDisabled(this.classIdx);
			}

			this.close();
			BAWK.play('ui_playconfirm');
		},
		onCancel () {
			this.gameOptionsPopup.options = deepClone(extern.GameOptions.value);
			this.close();
			BAWK.play('ui_popupclose');
		},
		onOkClicked () {
			this.close();
			BAWK.play('ui_popupclose');
		},
		onSettingAdjusted (id, value) {
			var adjuster = this.gameOptionsPopup.adjusters.find( (a) => { return a.id === id; });
			if (adjuster) {
				adjuster.value = value;
				this.gameOptionsPopup.changesMade = true;
			}
		},
		toggleWeaponClass (classIdx) {
			this.gameOptionsPopup.changesMade = true;
			this.gameOptionsPopup.options.weaponDisabled[classIdx] = !this.gameOptionsPopup.options.weaponDisabled[classIdx];
		},
		checkboxChange (e) {
			this.gameOptionsPopup.changesMade = true;
		},
		init () {
			this.gameOptionsPopup.togglers.forEach(t => {
				t.value = this.gameOptionsPopup.options.flags & extern.GameFlags[t.id] ? true : false;
			});

			this.gameOptionsPopup.adjusters.forEach(a => {
				a.value = this.gameOptionsPopup.options[a.id];
			});
		},
		close () {
			this.$refs.gameOptionsPopup.close();
			vueApp.onGameOptionsClosed();
		},
		resetGame () {
			this.gameOptionsPopup.changesMade = true;
			this.gameOptionsPopup.resetClicked = true;
			extern.sendGameAction(extern.GameActions.reset);
		}
    },
	computed: {
		inGame: () => {
			return extern.inGame;
		}
	}
}
</script><script id="notification-content" type="text/x-template">
   <!-- Popup: Give Stuff -->
   <!-- <large-popup id="giveStuffPopup" ref="giveStuffPopup" :popup-model="giveStuffPopup" @popup-closed="onSharedPopupClosed" :class="giveStuffPopup.type"> -->
	<div id="give-stuff-wrap" class="f_row gap-1">
		<div v-for="notify in notification" class="notification-content" :class="typeBg(notify.type)">
			<section>
				<notification-slider v-if="notify.data.items.length > 0" :loc="loc" :items="notify.data.items" :type="notify.type" :ids="notify.data.ids" @open-bundle="openBundle" @close-popup="onClosePopup" @close-item="onItemClosed"></notification-slider>
				<div v-show="(notify.data.eggs) && eggsActive" class="notify-group notify-group-eggs  f_col justify-content-center roundme_lg box_relative" :class="eggPackClass(notify.data.eggs)">
					<button @click="onEggPackClosed" class="popup_close clickme roundme_sm"><i class="fas fa-times text_blue5 fa-2x"></i></button>
					<div class="egg-give-stuff">
						<header>
							<h1 class="text-center">{{ rewardTitle }}</h1>
						</header>
						<img  src="img/egg_pack_small.webp" />
						<h2><img class="vertical-align-middle width_1 egg-img" src="img/svg/ico_goldenEgg.svg" />{{notify.data.eggs}}</h2>
						<p class="item-name text-center text_blue5">{{eggName(notify.data.eggs)}}</p>
						<button v-if="bonus" @click="goToShop" class="ss_button btn_lg btn_green bevel_green f_row align-items-center justify-content-center fullwidth">{{loc.account_creation_popup_button}}</button>
					</div>
				</div>
			</section>	
		</div>
	</div>
</script>

<script id="notification-slider" type="text/x-template">
	<div v-if="active" class="notify-group notify-group-items f_col justify-content-center roundme_lg box_relative" :class="clsType">
		<div v-if="isChallenge" class="notify-group-challenges-checkmark-wrap">
			<icon name="ico-checkmark"></icon>
		</div>
		<button v-if="endOfItems" @click="closeItem" class="popup_close clickme roundme_sm text_blue5"><i class="fas fa-times text_blue5 fa-2x"></i></button>
		<img v-if="isVip" class="vip-emblem centered_x lazy-load" v-lazyload :data-src="imgSrc">
		<header v-if="!isChallenge">
			<h1 class="text-center">{{ title }}</h1>
		</header>
		<item v-if="type !== 'challenges'" v-for="(i, idx) in items" v-show="idx === notifyIdx" :loc="loc" :item="i" :key="i.id" :isSelected="false" :show-item-only="true" :notify="true"></item>
		<div v-if="type == 'challenges' && chlg.length > 0" v-for="(i, idx) in chlg" v-show="idx === notifyIdx">
			<h1 class="text_white text-center text-shadow-black-40">Challenge Complete!</h1>
			<img v-if="isChallenge" class="chlg-icon display-block center_h" :src="chlgImg(i.loc_ref)">
			<h3 class="text_blue5 text-center nospace" v-html="chlgName(i.loc_ref)"></h3>
			<p class="text-center text_blue5 nospace" v-html="chlgDesc(i.loc_ref)"></p>
			<div class="account_eggs roundme_sm clickme f_row justify-content-center ss_margintop_lg ss_marginbottom_lg">
				<span class="egg_count text-center text-shadow-black-40"><img src="img/svg/ico_goldenEgg.svg" class="egg_icon"> {{ i.reward }}</span>
			</div>
		</div>
		<!-- challenges -->
		<button v-show="!isSingleItem " @click="nextItem" class="ss_button f_row align-items-center justify-content-center" :class="btnStyle">{{btnTxt}} <i class="fas fa-caret-right fa-2x" v-show="!endOfItems && !isChallenge"></i></button>
	</div>
</script>


<script>
const NotifiSlider = {
	template: '#notification-slider',
	components: {
		'item': comp_item,
	},
	props: ['loc', 'items', 'type', 'ids'],

	data: function () {
		return {
			notifyIdx: 0,
			active: true,
			lastIdx: this.items.length,
			chlg: [],
			bundleTxt: [
				'Cluck yeah!',
				"Keep em' coming!",
				"There's more?",
				'See bundle',
			],
			vipTxt: [
				'Ooh... shiny!',
				"Golden",
				"Hallelujah!",
				'Ok',
			],
		}
	},
	methods: {
		nextItem() {
			if (this.notifyIdx < this.items.length - 1) {
				this.notifyIdx++;
			} else {
				// equip bundle
				if (this.isBundle) {
					this.$emit('open-bundle');
				}

				this.closeItem();
			}
		},
		closeItem() {
			this.active = false;
			this.$emit('close-item');
		},
		chlgName(ref) {
			return this.loc[`${ref}_title`];
		},
		chlgDesc(ref) {
			return this.loc[`${ref}_desc`];
		},
		chlgImg(ref) {
			return extern.playerChallenges.iconSrc(ref);
		}
	},

	computed: {
		btnTxt() {
			if (!this.isSingleItem) {
				if (this.isBundle) {
					return this.bundleTxt[this.notifyIdx];
				} else if (this.isVip) {
					return this.vipTxt[this.notifyIdx];
				} else if (this.isChallenge) {
					return 'Claim';
				}
			}
		},
		endOfItems() {
			if (this.isSingleItem) {
				return true;
			} else {
				return this.notifyIdx === this.items.length - 1;
			}
		},
		isSingleItem() {
			return this.items.length === 1;
		},
		title() {
			switch (this.type) {
				case 'bundle':
					const product = extern.getProductTitle(this.ids);
					if (product[0].sku) {
						return this.loc[`${product[0].sku}_title`] + ' Bundle';
					}		
					break;
				case 'item':
					return this.loc.reward_title;
					break;
				case 'subscription':
					return 'Thanks for subscribing!';
					break;
				case 'challenge':
					return 'Thanks for subscribing!';
					break;
			
				default:
					break;
			}
		},
		isBundle() {
			return this.type === 'bundle';
		},
		isVip() {
			return this.type === 'subscription';
		},
		isChallenge() {
			if (this.type === 'challenges') {
				this.items.forEach(item => {
					extern.Challenges.find(el => {
						if (el.id === item) {
							this.chlg.push(el);
						}
					});
				});
				return true;
			}
		},
		clsType() {
			return `notify-group-${this.type}`
		},
		imgSrc() {
			if (this.isVip) {
				return 'img/vip-club/vip-club-popup-emblem.webp';
			}
		},
		btnStyle() {
			if (this.isChallenge) {
				return 'btn_sm btn_pink bevel_pink';
			}
			return 'btn_lg btn_green bevel_green';
		}
	},
};
</script>

<script>

	const notifiInitState = () => {
		return {
			eggBalance: 0,
			notifyIdx: 0,
			activeIdxs: 0,
			eggsActive: true
		}
	}

	const NotificationContent = {
		template: '#notification-content',
		components: {
			'notification-slider': NotifiSlider,
		},
		props: ['loc', 'notification', 'bonus'],

		data: function () {
			return notifiInitState();
		},

		methods: {
			resetState() {
				Object.assign(this.$data, notifiInitState());
			},
			onItemClosed() {
				if (!this.activeIdxs) {
					this.activeIdxs = this.notification.length;
				}
				this.activeIdxs--;
				if (this.activeIdxs === 0) {
					this.onClosePopup();
				}
			},
			onEggPackClosed() {
				this.eggsActive = false;
				
				this.onItemClosed();
			},
			onGiveStuffComplete: function () {
				this.giveStuffPopup.eggOrg = false;
				this.giveStuffPopup.rickroll = false;
				vueApp.onGiveStuffComplete();
			},
			onClickTwitchDropsMore() {
				window.open(dynamicContentPrefix + 'twitch');
				this.onGiveStuffComplete();
			},
			typeBg(type) {
				switch (type) {
					case 'vip':
						return 'bg_blue5';
						break;
					
					case 'purchases':
						return 'bg_blue6';
						break;

					case 'challenges':
						return '';
						break;
			
					default:
						return '';
						break;
				}
			},
			getProductTitle(data) {
				const product = extern.getProductTitle(data);
				if (product[0].sku) {
					return this.loc[`${product[0].sku}_title`];
				}
			},
			openBundle() {
				this.$emit('open-bundle', this.activeIdxs);
			},
			onClosePopup() {
				this.$emit('close-popup');
			},
			eggPackClass(eggs) {
				const name = extern.getProductTitleByEggVaule(eggs);
				if (name) {
					return name;
				}
			},
			eggName(eggs) {
				const name = extern.getProductTitleByEggVaule(eggs);
				if (name) {
					return this.loc[name + '_title'] + ' EGGS!';
				}
			},
			goToShop() {
				this.onEggPackClosed();
				if (vueApp.ui.bonus.showing) {
					vueApp.ui.bonus.showing = false;
					vueApp.openEquipSwitchTo(vueData.equipMode.skins, ItemType.Hat);
				} else {
					vueApp.openEquipSwitchTo(vueData.equipMode.skins);
				}
			}
		},
		computed: {
			rewardTitle() {
				if (this.bonus) {
					return this.loc.account_creation_popup_title;
				} else {
					this.loc.reward_title;
				}
			},
		}
	};
</script>


<script>


	function startVue(languageCode, locData) {

		vueData.extern = extern;
		vueData.loc = locData;

		extern.GameOptions.init();

		Vue.directive("lazyload", {
			inserted(el) {
				const observer = new IntersectionObserver((entries, observer) => {
				entries.forEach((entry) => {
					if (entry.isIntersecting) {
					const img = entry.target;

					if (img.dataset.src) {
						img.src = img.dataset.src; // Set src attribute from data-src
						img.removeAttribute("data-src"); // Remove data-src once loaded
					}

					img.classList.add("loaded"); // Optional class for transition
					img.classList.remove("lazy-load");

					observer.unobserve(img); // Stop observing once image is loaded
					}
				});
				});

				observer.observe(el);
			}
		});
		
		vueApp = new Vue({
			el: '#app',
			components: {
				'dark-overlay': comp_dark_overlay,
				'light-overlay': comp_light_overlay,
				'spinner-overlay': comp_spinner_overlay,
				'gdpr': comp_gdpr,
				'settings': comp_settings,
				'help': comp_help,
				'vip-help': vip_help,
				'subscription-store': compVipClubTemplate,
				// 'subscription-store': comp_egg_store,
				'item': comp_item,
				'home-screen': comp_home_screen,
				'equip-screen': comp_equip_screen,
				'game-screen': comp_game_screen,
				'gold-chicken-popup': comp_gold_chicken_popup,
				'chicken-nugget-popup': comp_chickn_winner_popup,
				'egg-store-item': comp_store_item,
				'give-stuff-popup': GIVESTUFFPOPUP,
				'game-options-popup': comp_game_options_popup,
				'main-sidebar': COMPMAINSIDE,
				'account-panel': comp_account_panel,
				'house-ad': CompHouseAd,
				'photo-booth-ui': CompPhotoboothUi,
				'notification-content': NotificationContent,
				'social-panel': comp_social_panel,
				'chw': CompChwHomeScreen
			},

			data: vueData,

			createdTime: null,
			mountedTime: null,
			fullyRenderedTime: null,
			
			multisizeAdTag: null,

			created () {
				console.log('Vue instance created');
				createdTime = performance.now();
				this.currentLanguageCode = languageCode;
				this.urlParams = parsedUrl.query.open ? parsedUrl.query.open : null;
			},

			mounted () {
				console.log('Vue instance mounted');
				mountedTime = performance.now();
				console.log('create -> mount time (ms): ' + (mountedTime - createdTime));
				this.currentGameType = extern.gameType;

				// Cannot modify data within the mounted hook, so wait until next tick
				this.$nextTick(function () {
					fullyRenderedTime = performance.now();
					console.log('mounted -> fully rendered time (ms): ' + (fullyRenderedTime - mountedTime));
					console.log('created -> fully rendered time (ms): ' + (fullyRenderedTime - createdTime));

					this.ready = true;

					this.getLocLang();
					extern.continueStartup();
					this.changelog.version = extern.version;
					this.changelog.current = this.changelogContent();
					this.ui.crazyGames = crazyGamesActive;
					this.resetGameOptions();

					this.$refs.headerAdContainer.appendChild(this.$refs.homeScreen.$refs.displayAdHeader);
				});

				// window.addEventListener('visibilitychange', () => this.handleVisibilityChange(), false);
    			// window.addEventListener('focus', () => this.handleVisibilityChange(true), false);
    			// window.addEventListener('blur', () => this.handleVisibilityChange(false), false);
			},

			methods: {
				getGameElements: function () {
					return {
						canvas: this.$refs.canvas,
						canvasWrapper: this.$refs.canvasWrapper,
					}
				},

				onShowloginPopupWarning() {
					if (extern.inGame) {
						this.$refs.loginPopupWarning.show();
					}
				},

				// handleVisibilityChange(val) {
				// 	if (document.hidden || document.visibilityState !== 'visible' || !val) {
				// 		this.setDisplayAdVisibility(false);
				// 	} else  {
				// 		this.setDisplayAdVisibility(true);
				// 	}
				// },

				playMusic: function () {
					myAudio = new Audio('./sound/theme');
					// Uncomment for looping.
					// myAudio.addEventListener('ended', function() {
					//     this.currentTime = 0;
					//     this.play();
					// }, false);
					myAudio.volume = this.volume;
					myAudio.play();
				},

				changeLanguage: function (languageCode) {
					extern.getLanguageData(languageCode, this.setLocData);
				},

				setLocData: function (languageCode, newLocData) {
					this.currentLanguageCode = getStoredString('languageSelected', null) ? localStore.getItem('languageSelected') : languageCode;
					this.loc = newLocData;
				},

				setPlayerName: function (playerName) {
					this.playerName = playerName.substring(0, 128);
				},

				showSpinner: function (headerLocKey, footerLocKey, showTips) {
					this.$refs.spinnerOverlay.show(headerLocKey, footerLocKey, showTips);
				},

				showSpinnerLoadProgress: function (percent) {
					this.$refs.spinnerOverlay.showSpinnerLoadProgress(percent);
				},

				hideSpinner: function () {
					this.$refs.spinnerOverlay.hide();
				},

				onSettingsPopupOpened: function () {
					this.$refs.settings.captureOriginalSettings();
					this.sharedIngamePopupOpened();
				},

				onSettingsPopupSwitchTabMisc: function () {
					this.$refs.settings.switchTab('misc_button');
				},

				onSettingsX: function () {
					this.$refs.settings.applyOriginalSettings();
					this.$refs.settings.cancelLanguageSelect();
					this.sharedIngamePopupClosed();
				},

				onSettingsQuickSave() {
					this.$refs.settings.quickSave();
				},

				onNoAnonPopupConfirm: function () {
					ga('send', 'event', this.googleAnalytics.cat.playerStats, this.googleAnalytics.action.denyAnonUserPopup, this.googleAnalytics.label.signInClick);
					this.showFirebaseSignIn();
				},

				onSharedPopupClosed: function () {
					// If in-game, show game menu after closing the popup
					this.blackFridayBanner = false;
					// if (this.showScreen === this.screens.game && extern.inGame) {
					// 	this.showGameMenu();
					// }
				},

				sharedIngamePopupOpened() {
					if (extern.inGame) this.$refs.gameScreen.sharedPopupOpened();
				},

				sharedIngamePopupClosed() {
					if (extern.inGame) this.$refs.gameScreen.sharedPopupClosed();
				},

				abTestshowEggReward(data) {
					if (this.abTestInventory.closed) {
						this.showGameMenu();
						return;
					}
					this.abTestInventory.enabled = true;
					this.showGiveStuffPopup(data.loc, data.amount, data.items, data.type);
				},
				abTestInventoryShowItem() {
					this.abTestInventorySetup();
				},
				adTestInventoryClickReset() {
					this.abTestInventory.currentIdx = 0;
					this.abTestInventory.enabled = false;
					this.$refs.abTestContainer.classList.add('hideme');
					this.setDarkOverlay(false);
				},
				abTestInventoryUiClicked() {
					if (!this.abTestInventory.enabled) {
						return;
					}

					let { currentIdx, clickables, enabled } = this.abTestInventory;
					let showIdx = currentIdx;
					let prevIdx = Math.max(currentIdx - 1, 0);

					this.$nextTick(() => {
						
						this.$refs.mainAside.style.zIndex = 'auto';

						// Check if the current index exceeds the length of clickables
						if (currentIdx >= clickables.length) {
							let prevEl = document.querySelector(`.${clickables[prevIdx].id}`);
							this.$refs.mainAside.style.zIndex = '';

							if (prevEl) {
								prevEl.style.zIndex = 2;
							}

							this.adTestInventoryClickReset();
							return; // Stop further execution
						}

						let newEl = clickables[showIdx].id ? document.querySelector(`.${clickables[showIdx].id}`) : null;
						let prevEl = clickables[prevIdx].id ? document.querySelector(`.${clickables[prevIdx].id}`) : null;

						// hack

						if (newEl) {
							if (clickables[currentIdx].scroll) {
								newEl.scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' });
							}

							newEl.classList.add('box_relative');
							newEl.appendChild(this.$refs.abTestContainer);
							this.$refs.abTestContainer.classList.remove('hideme');
							newEl.style.zIndex = 9000;

							// Set up the event listener to fire only once
							newEl.addEventListener('click', this.abTestInventoryUiClicked, { once: true });
						} else {
							this.$refs.abTestContainer.classList.add('hideme');
						}

						if (prevEl && newEl !== prevEl) {
							prevEl.style.zIndex = '';
						}

						// Increment the index and set the dark overlay
						this.setDarkOverlay(true);
						this.abTestInventory.currentIdx += 1;
					});
				},
				abTestInventorySetup() {
					this.abTestInventoryUiClicked();

				},
				abTestInventoryCompleted() {
					this.$refs.mainAside.style.zIndex = 2;
					this.abTestInventory.enabled = false;
					this.abTestInventory.started = false;
				},
				abTestInventoryCancel() {
					if (this.abTestInventory.enabled && !this.abTestInventory.started) {

						if (!extern.inGame) {
							this.$refs.giveStuffPopup.$refs.giveStuffPopup.hide();
						}
						extern.aBTestNoobInventoryCancel();
						this.adTestInventoryClickReset();
						this.showGameMenu();
						if (this.eggs >= 1250) {
							this.eggs = this.eggs - 1250;
						}
						this.abTestInventory.closed = true;
						return;
					}
				},
				onGiveStuffComplete: function () {
					if (this.abTestInventory.enabled) {
						this.abTestInventory.started = true;
						this.abTestInventoryShowItem();
						ga('set', 'ABTestGroup', 'noob_inventory_started');
						this.$refs.giveStuffPopup.$refs.giveStuffPopup.hide();
						return;
					}
					this.$refs.giveStuffPopup.$refs.giveStuffPopup.hide();
					if (extern.inGame) {
						this.showGameMenu();
						if (this.$refs.equipScreen.showScreen === this.$refs.equipScreen.screens.equip) {
							vueApp.setDarkOverlay(false);
						}
					}
				},

				onGiveStuffPopupClosed() {
					// abtest only
					this.$nextTick(() => {
						this.abTestInventoryCancel();
					});
				},

				onPrivacyOptionsOpened: function () {
					this.showPrivacyPopup();
				},
				/**
				 * Creates a generic popup that passes content 3 data options to slots on the genericPopup smallPopup
				 * @param titleLockKey mixed - popup header text
				 * @param contentLocKey mixed- popup content
				 * @param confirmLocKey mixed - popup button text
				 */
				showGenericPopup: function (titleLocKey, contentLocKey, confirmLocKey) {
					this.genericMessagePopup.titleLocKey = titleLocKey;
					this.genericMessagePopup.contentLocKey = contentLocKey;
					this.genericMessagePopup.confirmLocKey = confirmLocKey;
					this.hidePausePopupIfGenericPopupOpen();
					this.$refs.genericPopup.show();
				},
				hidePausePopupIfGenericPopupOpen: function() {

					if (!this.$refs.gameScreen.$refs.pausePopup && $refs.gameScreen.$refs.pausePopup.isShowing === false) {
						return;
					}

					// return this.$refs.gameScreen.$refs.pausePopup.hide();
				},
				showOpenUrlPopup: function (url, titleLocKey, content, confirmLocKey, cancelLocKey) {
					console.log('title: ' + this.loc[titleLocKey]);
					console.log('confirm: ' + this.loc[confirmLocKey]);
					console.log('cancel: ' + this.loc[cancelLocKey]);

					this.openUrlPopup.url = url;
					this.openUrlPopup.titleLocKey = titleLocKey;
					this.openUrlPopup.content = content;
					this.openUrlPopup.confirmLocKey = confirmLocKey;
					this.openUrlPopup.cancelLocKey = cancelLocKey;
					this.$refs.openUrlPopup.show();
				},

				onOpenUrlPopupConfirm: function () {
					extern.openUrlAndGiveReward();
				},

				showUnsupportedPlatformPopup: function (contentLocKey) {
					this.showScreen = -1;
					this.unsupportedPlatformPopup.contentLocKey = contentLocKey;
					this.$refs.unsupportedPlatformPopup.show();
				},

				showMissingFeaturesPopup: function () {
					this.showScreen = -1;
					this.$refs.missingFeaturesPopup.show();
				},

				showFirebaseSignIn: function () {
					this.$refs.homeScreen.showSignIn();
				},

				hideFirebaseSignIn: function () {
					this.$refs.firebaseSignInPopup.hide();
				},

				showCheckEmail: function () {
					this.$refs.homeScreen.$refs.checkEmailPopup.show();
				},

				hideCheckEmail: function () {
					this.$refs.homeScreen.$refs.checkEmailPopup.hide();
				},

				showResendEmail: function () {
					this.$refs.homeScreen.$refs.resendEmailPopup.show();
				},

				hideResendEmail: function () {
					this.$refs.homeScreen.$refs.resendEmailPopup.hide();
				},

				dontShowChwStuff() {
					return (extern.inGame || (this.isChicknWinnerError || !this.chw.ready || this.chw.winnerCounter > 3))
				},

				showChickenPopup: function () {

					if (this.dontShowChwStuff()) {
						return;
					}

					const show = localStore.getItem('chickenPopupShow'),
						  today = new Date(),
						  dd = String(today.getDate()).padStart(2, '0'),
						  mm = String(today.getMonth() + 1).padStart(2, '0'), //January is 0!
						  yyyy = today.getFullYear(),
						  whole = dd + mm + yyyy;

					if (!show || show !== whole) {
						this.$refs.goldChickenPopup.show();
						localStore.setItem('chickenPopupShow', whole);
					}
				},

				hideChickenPopup: function () {
					this.$refs.goldChickenPopup.hide();
					ga('send', 'event', 'Chickn Winner', 'chw-cta-popup', 'click-close-btn' );
				},

				goldChickenPopupOpenChw() {
					this.hideChickenPopup();
					if (this.dontShowChwStuff()) {
						return;
					}

					ga('send', 'event', 'Chickn Winner', 'chw-cta-popup', 'click-play-btn' );

					this.chwDoIncentivized();
				},

				showHelpPopup: function () {
					if (!extern.inGame) {
						this.hideGameMenu();
					}
					this.$refs.helpPopup.show();
				},

				showHelpPopupFeedbackWithDelete() {
					this.$refs.help.openFeedbackTabWith(this.feedbackType.delete.id);
					this.showHelpPopup();
				},

				showVipPopup: function () {
					if (!extern.inGame) {
						this.hideGameMenu();
					}
					BAWK.play('ui_popupopen');
					this.$refs.vipPopup.show();
				},

				showAttentionPopup: function () {
					if (!extern.inGame) {
						this.hideGameMenu();
					}
					this.$refs.anonWarningPopup.show();
				},

				hideHelpPopup: function () {
					this.$refs.helpPopup.hide();
				},

				showSettingsPopup: function () {
					if (!extern.inGame) {
						this.hideGameMenu();
					}
					this.$refs.settingsPopup.show();
					extern.settingsMenuOpened();
					this.sharedIngamePopupOpened();
				},

				hideSettingsPopup: function () {
					this.$refs.settingsPopup.hide();
				},

            showEggStorePopup: function () {
                this.$nextTick(() => {
                    this.hideGameMenu();
                    this.$refs.eggStorePopup.show();
                    if (this.isSale) {
                        this.blackFridayBanner = true;
                    }
                    ga('send', 'event', this.googleAnalytics.cat.itemShop, this.googleAnalytics.action.shopItemNeedMoreEggsPopup, this.googleAnalytics.label.getMoreEggs);
                });
            },

			showSubStorePopup: function () {
				this.$nextTick(() => {
					if (!extern.inGame) {
						this.hideGameMenu();
					}
					this.$refs.subStorePopup.show();
					BAWK.play('ui_popupopen');
					// ga('send', 'event', this.googleAnalytics.cat.itemShop, this.googleAnalytics.action.shopItemNeedMoreEggsPopup, this.googleAnalytics.label.getMoreEggs);
				});
			},

			vipEndedPopup() {
				this.$refs.vipEnded.show();
				BAWK.play('ui_popupopen');
			},

			showPopupEggStoreSingle(sku) {
				if (!sku) {
					console.log('No sku for popup');
					return;
				}
				if (!this.premiumShopItems.some( i => i.sku === sku)) {
					vueApp.showGenericPopup("uh_oh", "p_egg_shop_no_item_desc", "ok");
					return;
				}

				this.eggStorePopupSku = sku;
				this.$refs.popupEggStoreSingle.show();
			},

			hidePopupEggStoreSingle() {
				this.eggStorePopupSku = null;
				this.$refs.popupEggStoreSingle.hide();
			},

			hideEggStorePopup: function () {
				this.$refs.eggStorePopup.hide();
			},

			showChangelogPopup: function () {
				this.$refs.changelogPopup.show();
			},

			showHistoryChangelogPopup() {
				fetch('./changelog/oldChangelog.json', {cache: "no-cache"})
					.then(response => response.json())
					.then(data => {
						data.forEach((log, idx) => {
							const content = this.changelogSetup(log);
							log.content.length = 0;
							log.content.push(...content);
							this.changelog.current.push(log)
						});
				});

				this.changelog.showHistoryBtn = false;
			},

			hideChangelogPopup: function () {
				this.$refs.changelogPopup.hide();
			},

			photoBoothTypeChange() {
					this.$refs.photoBooth.updateTypeVisibility(this.equip.selectedItemType);
			},

			openPhotoBooth() {
				this.$nextTick().then( () => {
					this.openEquipSwitchTo(this.equipMode.inventory);
					this.$nextTick().then(() => {
						this.switchToPhotoBoothUi();
					});
				});
			},

			switchToPhotoBoothUi: function () {

				const homeDisplayAd = document.getElementById('shellshockers_titlescreen_wrap');
				const homeDisplayAdChild = homeDisplayAd ? homeDisplayAd.firstElementChild : null;

				this.ui.showHomeEquipUi = this.ui.showHomeEquipUi ? false : true;
				this.$refs.photoBooth.$refs.photoBoothDisplayAd.classList.toggle('hideme', this.ui.showHomeEquipUi);

				if (this.ui.showHomeEquipUi) {
					extern.photoBooth.close();
					if (homeDisplayAd) {
						homeDisplayAd.appendChild(this.$refs.photoBooth.$refs.photoBoothDisplayAd.firstElementChild);
					}
				} else {
					extern.photoBooth.open();
					if (homeDisplayAdChild) {
						this.$refs.photoBooth.$refs.photoBoothDisplayAd.appendChild(homeDisplayAdChild);
						this.showTitleScreenAd();
					}					
				}
				ga('send', 'event', 'photo-booth', 'click', this.ui.showHomeEquipUi ? 'close' : 'open');
				BAWK.play('ui_toggletab');
			},

			onPhotoboothBgColorChange(bgClass) {
				document.getElementById('ss_background').className = bgClass;
			},

			onPhotoBoothBgImageChange(url) {
				document.getElementById('ss_background').style.backgroundImage = (url && url !== 'none') ? `url(img/photo-booth/maps/${url}.webp)` : '';
			},

			onPhotoBoothHideUi(show) {
				if (!show) {
					this.showScreen = -1;
				} else {
					this.showScreen = this.screens.equip;
				}
			},

			// photoBoothVignetteChange(val) {
			// 	this.ui.photoBooth.vignette = val;
			// },

			screenGrabDone(canvasData) {
				this.$refs.photoBooth.screenGrabDone(canvasData);
			},

			gameUiAddClassForNoScroll() {
				let html = document.getElementsByTagName("html")[0];
				html.classList.add('noScrollIngame');
			},

			showGiveStuffPopup: function (titleLoc, eggs, items, type, callback) {
				if (this.giveStuffPopup.eggOrg) {
					ga('send', 'event', 'Egg Org', 'Code Cracked', 'redeemed');
				}
				type = type || '';
				this.giveStuffPopup.titleLoc = titleLoc;
				this.giveStuffPopup.eggs = eggs;
				this.giveStuffPopup.items = items;
				this.giveStuffPopup.type = type;
				this.$refs.giveStuffPopup.$refs.giveStuffPopup.show();
				if (callback) callback();
			},

			showPurchasesPopup: function (types, callback) {
				this.$refs.notifiContent.resetState()
				this.ui.notification = types;
				this.$refs.notificationPopup.show();
				if (callback) callback();
			},

			showChallengesAutoClaimed(chlgs) {
				// [ { id: 11, status: 'claimed' } ]
				this.showPurchasesPopup({challenges: chlgs});

			},

			showEggOrgPopup() {
				this.giveStuffPopup.eggOrg = true;
				this.showGiveStuffPopup('p_give_stuff_title');
			},

			showShareLinkPopup: function (url) {
				if (!extern.inGame) {
					this.hideGameMenu();
				}
				this.game.shareLinkPopup.url = url;
				BAWK.play('ui_popupopen');
				this.$refs.gameScreen.$refs.shareLinkPopup.show();
			},

			hideShareLinkPopup() {
				if (!this.$refs.gameScreen.$refs.shareLinkPopup.isShowing) {
					return;
				}
				this.$refs.gameScreen.$refs.shareLinkPopup.hide();
			},

			showJoinPrivateGamePopup: function (code) {
				this.$refs.homeScreen.$refs.playPanel.showJoinPrivateGamePopup(code, true);
			},

			showCreateGamePopup: function (code) {

				if (this.screen !== this.screens.home) {
					this.switchToHomeUi();
				}

				this.$refs.homeScreen.$refs.playPanel.showJoinPrivateGamePopup();
			},

			showPrivateGamePopup() {
				this.$refs.homeScreen.$refs.playPanel.$refs.createPrivateGamePopup.toggle();
			},

			showBannedPopup: function (expire) {
				this.bannedPopup.expire = expire;
				//this.ui.notification = types;
				this.$refs.bannedPopup.show();
				//if (callback) callback();
			},


			onBackClick() {
				this.$refs.mainAside.style.zIndex = 2;
				this.$refs.equipScreen.onBackClick();
			},

			switchToHomeUi: function () {
				this.showScreen = this.screens.home;
				this.$refs.equipScreen.removeKeyboardStampPositionHandlers();
				this.equip.displayAdHeaderRefresh = true;
				BAWK.play('ui_toggletab');
				vueApp.showTitleScreenAd();
				this.gameUiRemoveClassForNoScroll();
				extern.resetPaperDoll();

				this.$nextTick( ()=> {
					if (this.chatInitiatesLogin) {
						this.chatInitiatesLogin = false;
						this.onSignInClicked();
					}
				});
			},

			switchToProfileUi: function () {
				this.showScreen = this.screens.profile;
				this.$refs.equipScreen.removeKeyboardStampPositionHandlers();
				this.equip.displayAdHeaderRefresh = true;
				this.hideGameMenu();
				BAWK.play('ui_toggletab');
				vueApp.showTitleScreenAd();
				this.gameUiRemoveClassForNoScroll();
			},

			openEquipSwitchTo: function (mode) {
				this.showScreen = this.screens.equip;
				this.$refs.equipScreen.setup();
				this.$refs.equipScreen.switchTo(mode);

				if (extern.inGame) {
					this.hideGameMenu();
					extern.openEquipInGame();
				}
				else {
					vueApp.hideTitleScreenAd();
				}
			},

			switchToGameUi: function () {
				this.showScreen = this.screens.game;
				this.$refs.equipScreen.removeKeyboardStampPositionHandlers();
				this.equip.displayAdHeaderRefresh = true;
			},

			gameUiAddClassForNoScroll() {
				let html = document.getElementsByTagName("html")[0];
				html.classList.add('noScrollIngame');
			},

			gameUiRemoveClassForNoScroll() {
				let html = document.getElementsByTagName("html")[0];
				html.classList.remove('noScrollIngame');
			},

			switchToGameUiQuickPlay () {
				this.showScreen = this.screens.game;
				this.ui.showCornerButtons = false;
				vueApp.hideTitleScreenAd();
				this.gameUiAddClassForNoScroll();
			},

			showGameMenu: function () {
				if (this.abTestInventory.enabled) {
					return;
				}
				this.$refs.gameScreen.showGameMenu();
			},

			hideGameMenu: function () {
				this.$refs.gameScreen.hideGameMenu();
			},

			onMiniGameCompleted: function () {
				this.$refs.homeScreen.onMiniGameCompleted();
			},

			setShellColor: function (colorIdx) {
				this.equip.colorIdx = colorIdx;
			},

			setAccountUpgraded: function (upgraded, endDate) {
				this.isUpgraded = upgraded;
				this.equip.extraColorsLocked = !this.isUpgraded;
				this.nugStart = endDate;

			},

			setDarkOverlay: function (visible, overlayClass) {
				this.$refs.darkOverlay.show = visible;
				this.$refs.darkOverlay.overlayClass = overlayClass;
			},

			setLightOverlay: function (visible, overlayClass) {
				this.$refs.lightOverlay.show = visible;
				this.$refs.darkOverlay.overlayClass = overlayClass;
			},

			authCompleted: function () {
				this.accountSettled = true;
				if (vueApp.$refs.firebaseSignInPopup.isShowing) this.hideFirebaseSignIn();
			},

			runProductCheck() {
				this.checkProducts++;
			},

			showItemOnEquipScreen: function (item, mode) {
				this.openEquipSwitchTo(mode);
				this.$refs.equipScreen.autoSelectItem(item);
			},

			showItem: function (item) {
				vueApp.openEquipSwitchTo(this.equipMode.inventory);
				this.$refs.equipScreen.autoSelectItem(item);
			},
			autoSelectItem(item) {
				this.$refs.equipScreen.autoSelectItem(item);
			},

			showTaggedItemsOnEquipScreen: function (tag) {
				this.openEquipSwitchTo(this.equipMode.featured);
				this.$refs.equipScreen.showTaggedItems(tag);
			},

			useHouseAdSmall: function (smallHouseAd) {
				this.ui.houseAds.small = smallHouseAd;
			},

			useHouseAdBig: function (bigHouseAd) {
				this.ui.houseAds.big = bigHouseAd;
			},

			denyAnonUser: function () {
				ga('send', 'event', vueApp.googleAnalytics.cat.playerStats, vueApp.googleAnalytics.action.denyAnonUserPopup);
				if (extern.inGame) {
					this.hideGameMenu();
				}
				this.$refs.noAnonPopup.show();
			},

			showGdprNotification: function () {
				this.$refs.gdpr.show();
			},

			showPrivacyPopup: function () {
				this.hideSettingsPopup();
				this.$refs.privacyPopup.show();
			},

			hidePrivacyPopup: function () {
				this.$refs.privacyPopup.hide();
				this.showSettingsPopup();
			},

			ofAgeChanged: function () {
				extern.setOfAge(this.isOfAge);
				BAWK.play('ui_onchange');
			},

			targetedAdsChanged: function () {
				extern.setTargetedAds(this.showTargetedAds);
				BAWK.play('ui_onchange');
			},

			setPrivacySettings: function (ofAge, targetedAds) {
				this.isOfAge = ofAge;
				this.showTargetedAds = targetedAds;
			},

			gameJoined: function (gameType, team) {
				this.game.gameType = gameType;
				this.setTeam(team);
			},

			setTeam: function (team) {
				if (hasValue(team)) {
					this.game.team = team;
				}
			},

			showGoldChickenPopup: function () {
				this.$refs.goldChickenPopup.show();
			},

			hideGoldChickenPopup: function () {
				this.$refs.goldChickenPopup.hide();
			},

			showChicknWinnerPopup: function () {
				this.$refs.chicknWinner.show();
				this.$refs.nuggetDisplayAd.show();
				this.isBuyNugget = true;
			},

			hideChicknWinnerPopup: function () {
				this.$refs.chicknWinner.hide();
				this.$refs.chickenNugget.onGotWinner();
				console.log('Hide nugget');
			},

			chicknWinnerIsReady() {
				if (this.chw.limitReached) {
					this.chwOnClick(true);
					return;
				}
			},

			chwAdBlockerDetected() {
				this.chw.adBlockDetect = true;
			},

			chicknWinnerError(val) {
				this.isChicknWinnerError = val;
			},

			chicknWinnerDailyLimit() {
				this.chicknWinnerDailyLimitReached = true;
			},

			loadNuggetVideo() {
				if (!extern.inGame) {
					this.hideGameMenu();
				}
				this.chwDoIncentivized();
				BAWK.play('ui_playconfirm');
			},

			chwDoIncentivized() {
				extern.chwTryPlay();
			},

			chwOnClick(val) {
				this.chw.onClick = val;
			},

			chwMiniGameCompleted(val) {
				this.$refs.nuggetDisplayAd.destroyAd();
				this.chwMiniGameComplete = val;
				this.chw.nuggetReset += 1;
				setTimeout(() => this.chwOnClick(false), 1000);
			},
			
			onChwPopupClosed() {
				this.$refs.chickenNugget.resetGame();
			},

				placeBannerAdTagForNugget: function (tagEl) {
					this.$refs.chickenNugget.placeBannerAdTag(tagEl);
				},

				useSpecialItemsTag: function (tag) {
					this.equip.specialItemsTag = tag;
					this.equip.showSpecialItems = true;
				},

				disableSpecialItems: function () {
					this.equip.showSpecialItems = false;
				},

				setUiSettings: function (settings) {
					this.settingsUi.settings = settings;
					this.$refs.settings.setSettings(settings);
				},

				showPlayerActionsPopup: function (slot) {
					if (this.showAdBlockerVideoAd) {
						return;
					}

					this.playerActionsPopup = slot;
					this.$refs.gameScreen.showPlayerActionsPopup();
				},
				onSignInCancelClicked: function () {
					vueApp.$refs.firebaseSignInPopup.hide();
					BAWK.play('ui_popupclose');
				},
				anonWarningPopupCancel: function() {
					let anonWarnConfrimed = localStore.getItem('anonWarningConfirmed');
					this.urlParamSet = this.urlParams ? true : null;
					this.shellShockUrlParamaterEvents();
					ga('send', 'event', this.googleAnalytics.cat.playerStats, this.googleAnalytics.action.anonymousPopupOpenAuto, this.googleAnalytics.label.understood);
					return anonWarnConfrimed === null && localStore.setItem('anonWarningConfirmed', true);
				},
				anonWarningPopupConfrim() {
					let anonWarnConfrimed = localStore.getItem('anonWarningConfirmed');
					anonWarnConfrimed === null && localStore.setItem('anonWarningConfirmed', true);
					ga('send', 'event', this.googleAnalytics.cat.playerStats, 'Account egg bonus popup', this.googleAnalytics.label.signInClick);
					extern.showSignInDialog();
					this.urlParamSet = false;
					vueApp.$refs.firebaseSignInPopup.show();
				},
				conditionalAnonWarningCall: function() {

					if (!this.isAnonymous || this.abTestInventory.enabled) {
						return;
					}

					// set eggTotal checks
					let lastIdx = localStore.getItem('anonPopupLastIdx');
					const allChecks = [100000, 90000, 80000, 70000, 60000, 50000, 40000, 30000, 20000, 10000, 1000, 100, 0];

					// Need to remove the all the past values so all the checks to run with each screen change
					lastIdx = lastIdx === null ? allChecks.length : lastIdx;
					const checks = allChecks.filter( (i, idx) => lastIdx > idx);

					// set localStore items to match the values in checks
					const localItems = [];
					checks.forEach((i, idx) => localItems.push(`anonPopup${i}`));

					for (let i = 0; i < localItems.length; i++) {
						if (localStore.getItem(localItems[i]) === null) {
							if (this.eggsEarnedBalance >= checks[i]) {
								this.showAttentionPopup();
								ga('send', 'event', this.googleAnalytics.cat.playerStats, 'Account egg bonus popup auto', checks[i]);
								localStore.setItem(localItems[i], true);
								localStore.setItem('anonPopupLastIdx', i);
								break;
							}
						}
					}
				},
				needMoreEggsPopupCall: function() {
					ga('send', 'event', this.googleAnalytics.cat.itemShop, this.googleAnalytics.action.shopItemNeedMoreEggsPopup);
					this.$refs.needMoreEggsPopup.show();
				},
				/**
				 * Not 100 % certain this should live in vue but here it is.
				 * Add the ability to use url paramaters to trigger events in the game.
				 * e.g. shellshock.io/?open=eggStore&type=Hat&item=1111 will open the spiderman hat item.
				 * Called in the extern closure under gameApp.js => afterGameReady()
				 */
				shellShockUrlParamaterEvents() {
					// VUE next tick https://vuejs.org/v2/api/#Vue-nextTick
					this.$nextTick( ()=> {
						this.doSsUlrParams();
					});
				},

				doSsUlrParams() {
					if ( ! this.urlParams) {
						return;
					}

					console.log(hasValue(this.isAnonymous));

					if (hasValue(this.ui.houseAds.big)) {
						this.urlParamSet = false;
						return;
					} else if (this.isAnonymous && ! hasValue(localStore.getItem('anonWarningConfirmed'))) {
						this.urlParamSet = false;
						console.log('Almost there!');
						this.conditionalAnonWarningCall();
						return;
					}

					console.log('Passed Popup gate');

					switch (this.urlParams) {
						case 'eggStore' :
							// Opens the purchase egg store popup
							this.showEggStorePopup();
							break;
						case 'goldenChicken' :
							// Opens the golden chicken popup
							vueApp.$refs.goldChickenPopup.show();
							break;
						case 'twoTimesTheEggs' :
							// Opens the chicken nugget video
								extern.chwTryPlay();
								BAWK.play('ui_playconfirm');
							break;
						case 'itemShop' :
							// Opens shop options
							// /?open=itemShop
							// /?open=itemShop&type=Hat/Stamp/Primary/Secondary/Grenade/Premium/Tagged 
							// /?open=itemShop&gunClass=Soldier/Soldier/Scrambler/Ranger/Eggsploder/Whipper/Crackshot/TriHard
							// /?open=itemShop&item=1111 opens hat store and then selects item
							// /?open=itemShop&item=1111&openBuyNow=1 opens hat store, selects item and then opens items popup
							this.openEquipSwitchTo(this.equipMode.shop);
							this.eggStoreUrlParams();
							break;
						case 'vipStore' :
							vueApp.showSubStorePopup();
							break;
						case 'redeem' :
							vueApp.openEquipSwitchTo(this.equipMode.inventory);
							BAWK.play('ui_popupopen');
							this.$refs.equipScreen.$refs.redeemCodePopup.show();
							if ('code' in parsedUrl.query) this.equip.redeemCodePopup.code = parsedUrl.query.code;
							break;
						case 'faq' :
							this.showHelpPopup();
							break;
						case 'taggedItems' : 
							this.openSpecialTagItemsTab();
							break;
						case 'privateGame' :
							this.showPrivateGamePopup();
							break;
						case 'kotcInstruction' : 
							// this.showKotcInstrucPopup();
							break;
						default:
							null;
					};
				},
				eggStoreUrlParams() {
					if (parsedUrl.query.hasOwnProperty('item')) {
						this.urlParamShowItem(parseInt(parsedUrl.query.item), parsedUrl.query.hasOwnProperty('openBuyNow'));
						return;
					} else if (parsedUrl.query.hasOwnProperty('type')) {
						this.urlParamShowItemType(parsedUrl.query.type);
						return;
					} else if (parsedUrl.query.hasOwnProperty('gunClass') && CharClass.hasOwnProperty(parsedUrl.query.gunClass)) {
						this.urlParamShowClass(parsedUrl.query.gunClass)
						return;
					}
				},
				urlParamShowItem(itemId, openBuy) {
					let item = extern.catalog.findItemById(itemId);
					if (!item.is_available) {
						vueApp.showGenericPopup("uh_oh", "no_anon_title", "ok");
						return;
					}
					this.$nextTick().then(() => {
						this.$refs.equipScreen.autoSelectItem(item);
						if (openBuy) {
							vueApp.$refs.equipScreen.onBuyItemClicked();
						}
					})
				},
				urlParamShowItemType(type) {
					if (ItemType.hasOwnProperty(type)) {
						this.$nextTick().then(() => this.equipSwitchTo('item', ItemType[parsedUrl.query.type]))
					} else if (type === 'Premium' || type === 'Tagged') {
						this.$nextTick().then(() => this.openEquipSwitchTo(this.equipMode.featured));	
					}
				},
				urlParamShowClass(gClass) {
					if (!CharClass.hasOwnProperty(gClass)) return;
					this.$nextTick().then(() => {
						this.equipSwitchTo('item', ItemType['Primary'])
						this.$nextTick().then(() => {
							this.openEquipSwitchTo(this.equipMode.skins);
							this.$nextTick().then(() => {
								this.equipSwitchTo('class', CharClass[gClass])
							})
						})
					})
				},
				equipSwitchTo(type, val) {
					switch (type) {
						case 'item':
							vueApp.$refs.equipScreen.switchItemType(val);
							break;
						case 'class':
							vueApp.$refs.equipScreen.$refs.weapon_select.selectClass(val);
							break;
						default:
							break;
					}
				},
				openSpecialTagItemsTab() {
					let tag = parsedUrl.query.tag ? parsedUrl.query.tag : null;
					vueApp.showTaggedItemsOnEquipScreen(tag);
				},

				delayInGamePlayButtons() {
					vueApp.$refs.gameScreen.delayGameMenuPlayButtons();
				},
				displayAdEventObject(event) {
					let object = event;
					this.displayAdObject = object.size[0];
				},
				//Call/hide display ads
				hideRespawnDisplayAd() {
					if (extern.productBlockAds) {
						return;
					}
					if (this.showScreen === this.screens.game) {
						this.$refs.gameScreen.$refs.headerDisplayAdGame.destroyAd();
						this.$refs.gameScreen.$refs.respawnDisplayAd.destroyAd();
						this.$refs.gameScreen.$refs.respawnTwoDisplayAd.destroyAd();
					}
				},
				showRespawnDisplayAd() {
					if (extern.productBlockAds || extern.abTestNoobNoAdsBlocks) {
						return;
					}
					if (!this.ui.tutorialPopup.show) {
						this.$refs.gameScreen.$refs.headerDisplayAdGame.show();
						this.$refs.gameScreen.$refs.respawnDisplayAd.show();
						this.$refs.gameScreen.$refs.respawnTwoDisplayAd.show();
					}
				},
				toggleRespawnDisplayAd(val) {
					if (extern.productBlockAds || extern.abTestNoobNoAdsBlocks) {
						return;
					}
					if (this.showScreen === this.screens.game) {
						this.$refs.gameScreen.$refs.headerDisplayAdGame.toggleAd(val);
						this.$refs.gameScreen.$refs.respawnDisplayAd.toggleAd(val);
						this.$refs.gameScreen.$refs.respawnTwoDisplayAd.toggleAd(val);

					}
				},
				setDisplayAdVisibility(val) {
					if (extern.productBlockAds) {
						return;
					}
					this.$refs.gameScreen.$refs.respawnDisplayAd.setWindowVisibility(val);
					this.$refs.gameScreen.$refs.respawnTwoDisplayAd.setWindowVisibility(val);
					this.$refs.homeScreen.$refs.titleScreenDisplayAd.setWindowVisibility(val);
					this.$refs.homeScreen.$refs.headerDisplayAd.setWindowVisibility(val);

				},
				hideLoadingScreenAd() {
					this.$refs.spinnerOverlay.$refs.loadingScreenDisplayAd.destroyAd()
				},
				showLoadingScreenAd() {
					if (extern.productBlockAds) {
						return;
					}

					if (this.ui.tutorialPopup.show) {
						return;
					}

					this.$refs.spinnerOverlay.$refs.loadingScreenDisplayAd.show();
					// this.histPushState({game: 3}, 'Shellshockers Loading display ad', '?loadingAd=true');
				},
				showTitleScreenAd() {

					if (extern.productBlockAds) {
						return;
					}

					this.$refs.homeScreen.$refs.titleScreenDisplayAd.show();

					if (!crazyGamesActive) {
						vueApp.showHeaderAd();
					} else {
						this.$nextTick(() => {
							crazySdk.requestResponsiveBanner('shellshockers_titlescreen_wrap');
						});
					}
				},

				// setTitleScreenAdVisibility(val) {
				// 	if (extern.productBlockAds && this.showScreen === this.screens.game) {
				// 		return;
				// 	}
				// 	this.$refs.homeScreen.$refs.titleScreenDisplayAd.setWindowVisibility(val);
				// 	this.$refs.homeScreen.$refs.headerDisplayAd.setWindowVisibility(val);
				// },
				hideTitleScreenAd(forceHide) {
					if (extern.productBlockAds && !forceHide) {
						return;
					}
					this.$refs.homeScreen.$refs.titleScreenDisplayAd.destroyAd(forceHide);
				},
				showHeaderAd() {
					if (extern.productBlockAds || extern.abTestNoobNoAdsBlocks) {
						return;
					}
					
					if (!crazyGamesActive) {
						this.$nextTick().then(() => {
							this.$refs.homeScreen.$refs.headerDisplayAd.show();
						})
					}

				},
				hideHeaderAd(forceHide) {
					if (extern.productBlockAds && !forceHide) {
						return;
					}
					this.$refs.homeScreen.$refs.headerDisplayAd.destroyAd(forceHide);
				},
				toggleTitleScreenAd(val) {
					if (extern.productBlockAds || this.showScreen === this.screens.game || extern.abTestNoobNoAdsBlocks) {
						return;
					}

					if (this.showScreen !== this.screens.equip) {
						this.$refs.homeScreen.$refs.titleScreenDisplayAd.toggleAd(val);
					}

					this.$refs.homeScreen.$refs.headerDisplayAd.toggleAd(val);
				},
				scrollToTop() {
					let position =
						document.body.scrollTop || document.documentElement.scrollTop,
						scrollAnimation;
					if (position) {
						window.scrollBy(0, -Math.max(1, Math.floor(position / 10)));
						scrollAnimation = setTimeout(this.scrollToTop, 10);
					} else clearTimeout(scrollAnimation);
				},
				externPlayObject(playType, gameType, playerName, mapIdx, joinCode) {
					extern.play({playType, gameType, playerName, mapIdx, joinCode});
				},
				pleaseWaitPopup() {
					vueApp.showGenericPopup("signin_auth_title", "signin_auth_msg");
				},
				isPlayingPoki() {
					this.isPoki = true;
					this.ready = true;
					return;
				},
				histPushState(obj, title, param) {
					return history.pushState(obj, title, param);
				},
				disablePlayButton(val) {
					const playBtns = document.querySelectorAll('.is-for-play');
					playBtns.forEach(btn => btn.disabled = val);
					this.playClicked = val;
					// document.querySelector('.play-button').disabled = val;
				},
				disableRespawnButton(val) {
					this.game.disableRespawn = val;
				},
				disaplyAdEventObject(event) {
					this.displayAdObject = event.size === null ? null : event.size[0];
				},
				adBlockerPopupToggle() {
					return vueApp.$refs.adBlockerPopup.toggle();
				},
				// musicPlayOnce() {
				//     return setTimeout(() => this.$refs.gameScreen.$refs.gameScreenMusic.playOnce(), 2000);
				// },
				// musicPause() {
				//     this.$refs.gameScreen.$refs.gameScreenMusic.pause();
				// },
				musicVolumeControl(value) {
					return;
					this.settingsUi.adjusters.music[0].value = Number(value);
					this.$refs.gameScreen.$refs.gameScreenMusic.loadVolume();
				},
				toggleMusic() {
					this.$refs.gameScreen.$refs.gameScreenMusic.toggleMusic();
				},
				musicWidget(val) {
					this.music.isMusic = val;
				},
				fetchSponsors() {
					fetch(this.music.musicJson)
						.then((response) => response.json())
						.then((sponsors) => this.music.sponsors = sponsors)
						.catch((error) => console.log('Sponsors fetch error', error));
				},
				pwaPopup() {
					return this.$refs.pwaPopup.show();
				},
				pwaBtnClick() {
					// Track the click
					ga('send', 'event', 'pwa', 'button', 'click');
					//close popup
					this.$refs.pwaPopup.hide();
					// Get the event
					this.pwaDeferEvent = extern.getPwaEvent;

					if (!this.pwaDeferEvent) {
						return;
					}
					this.pwaDeferEvent.prompt();

					this.pwaDeferEvent.userChoice
						.then((choiceResult) => {
							if (choiceResult.outcome === 'accepted') {
								console.log('User accepted the A2HS prompt');
							} else {
								console.log('User dismissed the A2HS prompt');
							}
							ga('send', 'event', 'pwa', 'a2hs', choiceResult.outcome);
							this.pwaDeferEvent = null;
						});

					this.pwaDeferEvent = '';
				},
				signOut() {
					this.isUpgraded = false;
					this.equip.extraColorsLocked = true;
					this.upgradeName = '';
					this.isSubscriber = false;
				},
				mediaTabsStartRotate() {
					const mediaTabs = this.$refs?.homeScreen?.$refs?.mediaTabs;
					
					if (mediaTabs && typeof mediaTabs.autoRotateTabs === 'function') {
						mediaTabs.autoRotateTabs();
					}
				},

				mediaTabsCancelRotate() {

					const mediaTabs = this.$refs?.homeScreen?.$refs?.mediaTabs;
				
					if (mediaTabs && typeof mediaTabs.autoRotateTabs === 'function') {
						mediaTabs.cancelRotate(true);
					}
				},

				stopClicksFAdBlocker(e) {
					e.stopPropagation();
					e.preventDefault();
				},
				showAdBlockerVideo() {
					document.addEventListener('click',this.stopClicksFAdBlocker, true);
					this.bannerHouseAd = extern.getHouseAd('bigBanner');
					this.showAdBlockerVideoAd = true;
					if (!extern.inGame) {
						this.hideGameMenu();
					}
					this.$refs.adBlockerVideo.show();
				},
				hideAdBlockerVideo() {
					document.removeEventListener("click", this.stopClicksFAdBlocker, true);  
					this.$refs.adBlockerVideo.hide();
					if (extern.inGame) {
						this.showGameMenu();
					}
					this.bannerHouseAd = {};
					this.showAdBlockerVideoAd = false;


				},
				// showKotcInstrucPopup() {
				// 	this.$refs.kotcInstrucPopup.show();
				// },
				// kotcInstrucPopupHide() {
				// 	this.$refs.kotcInstrucPopup.hide();
				// },
				onClickPlayKotcNow() {
					return;
					// this.externPlayObject(vueData.playTypes.joinPublic, 3, this.playerName, '', '');
					// this.kotcInstrucPopupHide();
				},
				onVipHelpClosed() {
					this.onSharedPopupClosed();
					this.showSubStorePopup();
				},
				getLocLang(val) {
					let data = this.loc,
						langSetup = {};
					if (val) data = val;

					const newLoc = Object.entries(data).filter(item => item[0].includes('locLang')).forEach(lang => langSetup[lang[0].split('_').pop('').split("-").pop('')] = lang[1]);
					this.$nextTick(() => {
						this.locLanguage = langSetup
					});
				},
				onClickTwitchDropsMore() {
					window.open(dynamicContentPrefix + 'twitch');
					this.onGiveStuffComplete();
				},
				onPremiumItemsClicked() {
					this.openEquipSwitchTo(this.equipMode.shop);
					this.$refs.equipScreen.onPremiumItemsClicked();
				},
				useTags(val) {
					this.ui.socialMedia.selected = val.socialMedia;
					this.ui.premiumFeaturedTag = val.premFeat;
				},
				onAccountDelectionConfirmed() {
					this.$refs.help.onAccountDelectionConfirmed();
				},
				showDeleteAccoutApprovalPopup() {
					this.$refs.deleteAccountApprovalPopup.show();
				},
				resetFeedbackType(){
					this.feedbackSelected = 0;
				},
				playIncentivizedAd(e) {
					
					const { adBlockDetect, ready, limitReached, onClick } = this.chw;
					const { inGame } = extern;

					if (onClick) {
						return;
					}

					if (this.showAdBlockerVideoAd || adBlockDetect || (!ready && !limitReached)) {
						return;
					}

					this.chwOnClick(true);

					const action = limitReached ? 'Reset' : 'Free eggs btn';
					const btnClick = inGame ? 'click-in-game' : 'click-home';

					if (limitReached) {
						extern.chwResetWithEggs();
					} else {
						if (inGame) {
							this.playChwIngame();
						}
						this.loadNuggetVideo();
					}

					// Track the event using Google Analytics
					ga('send', 'event', 'Chickn Winner', action, btnClick);
				},
				playChwIngame() {
					vueApp.hideGameMenu();
					vueApp.disableRespawnButton(true);
				},
				chwStopCycle() {
					if (this.chwHomeTimer) {
						clearInterval(this.chwHomeTimer);
						this.chwHomeTimer = '';
						this.chwHomeEl.classList.remove('.active');
					}
				},
				chwShowCycle() {
					this.chwHomeEl = document.querySelector('.chw-home-timer');
					if (this.chwHomeEl) {
					this.chwHomeTimer = setInterval(() => {
						this.chwHomeEl.classList.toggle('active');
						}, this.chwActiveTimer);
					}
				},

				// onHomeClicked() {
				// 	this.$refs.gameScreen.onHomeClicked();
				// },
				setInGame(val) {
					this.game.on = val;
				},
				setPause(val) {
					this.game.isPaused = val;
				},
				onHomeClicked: function () {
					BAWK.play('ui_click');
					this.hideRespawnDisplayAd();
					this.$refs.leaveGameConfirmPopup.show();
				},
				onLeaveGameConfirmedSignIn() {
					this.chatInitiatesLogin = true;
					this.onLeaveGameConfirm();
				},
				onLeaveGameConfirm: function () {
					this.$refs.gameScreen.onLeaveGameConfirm();
				},
				onLeaveGameCancel: function () {
					this.$refs.gameScreen.onLeaveGameCancel();
				},

				leaveGame: function () {
					this.$refs.gameScreen.leaveGame();
				},
				statsLoading() {
					if (!extern.inGame) {
						this.ui.game.stats.loading = false;
						return;
					}
					this.ui.game.stats.loading = this.ui.game.stats.loading ? false : true;
				},
				onSignInClicked() {
					BAWK.play('ui_playconfirm');
					this.$refs.homeScreen.onSignInClicked();
				},
				onSignOutClicked() {
					BAWK.play('ui_reset');
					this.$refs.homeScreen.onSignOutClicked();
				},
				showNuggyPopup() {
					if (this.chw.ready && this.firebaseId !== null) {
						return this.playIncentivizedAd()
					}
					this.showChicknWinnerPopup();
				},
				openUnblocked() {
					// if (crazyGamesActive) {
					// 	window.open('https://scrambled.world/unblocked');
					// }
					// else {
					// }
					window.open('unblocked');
				},
				onGameTypeChanged(val) {
					this.currentGameType = val;
				},
				onGamePauseUi() {
					this.$refs.gameScreen.pauseUi();
				},
				onChwSignInClicked() {
					this.chwSignInClicked = true
				},
				setUiGaugeMeterData(data) {
					this.$refs.homeScreen.$refs.gaugeMeter.setGaugeMeterData(data)
				},
				fbTransferAccountSignin() {
					this.hideFirebaseSignIn();
					BAWK.play('ui_popupopen');
					this.$refs.fbTransferAccountSignin.show();
				},

				setPreviousScreen(screen) {
					this.previousScreen = screen;
				},

				onTutorialPopupClick() {
					this.ui.tutorialPopup.show = true;

					if (!extern.inGame) {
						this.hideLoadingScreenAd();
					}

					this.$refs.tutorialPopup.show();
				},

				onTutorialClosed() {
					this.ui.tutorialPopup.show = false;

					if (!extern.inGame) {
						this.showLoadingScreenAd();
					} else {
						setTimeout(() => {
							this.showRespawnDisplayAd();
						}, 100);
					}
				},

				onGameOptionsClick() {
					this.$refs.gameOptionsPopup.onShow();
					this.$refs.gameOptionsPopup.$refs.gameOptionsPopup.show();
				},

				onGameOptionsClosed() {
					this.$refs.gameScreen.$forceUpdate();
					this.gameOptionsPopup.changesMade = false;
					setTimeout(() => {
						this.showRespawnDisplayAd();
					}, 100);
				},

				resetGameOptions () {
					extern.GameOptions.init();
				},

				openDevXsollaPopup(sku, sub) {
					this.$refs.xsollaPopup.show();
					this.dev.store.sku = sku;
				},

				xsollaPopupConfrim() {
					localStore.setItem('xsollaPopupConfrim', true);
					extern.buyProductForMoney(this.dev.store.sku);
					this.xsollaPopupCancel();
				},

				xsollaPopupCancel() {
					this.dev.store.sku = null;
				},
				changelogSetup(log) {
					const content = [];
					log.content.forEach((item, idx) => {
						if (Array.isArray(item)) {
							if (item[0]) {
								content.push(item[0]);
							} else {
								return;
							}
						} else {
							content.push(item);
						}
					});

					return content;
				},
				changelogContent() {
					const log = extern.changelogData[0];
					const content = this.changelogSetup(log);

					log.content.length = 0;
					log.content.push(...content);

					return [log];

				},

				onOpenBundle(itemsOpen) {
					if (itemsOpen === 0) {
						this.onCloseNotification();
					}
					this.openEquipSwitchTo(this.equipMode.shop);
				},

				onCloseNotification() {
					this.$refs.notificationPopup.hide();
				},
				timeFormat (time) {
					return time.toString().length < 2 ? `0${time}` : `${time}`;
				},
				
				chwUiTimerUpdate(hours, minutes, seconds, progress, ready, limitReached, count, resets) {
					this.chw.hours = hours ? this.timeFormat(hours) : 0;
					this.chw.minutes = this.timeFormat(minutes);
					this.chw.seconds = this.timeFormat(seconds);
					this.chw.progress = progress;
					this.chw.ready = ready;
					this.chw.limitReached = limitReached;
					this.chw.winnerCounter = count;
					this.chw.resets = resets;
				},
				chwHomeForceReset() {
					this.chwOnClick(false);
					this.$refs.chwHomeScreen.$forceUpdate();
				},
				getChwPlayAdText() {
					return this.playAdText;
				},
				getChwRemainingMsg() {
					return this.remainingMsg;
				},
				setGameDataUi(map) {
					this.game.mapName = map;
				},
				killDeathMsg(msg) {
					this.game.killDeathMsg.msgs.push(msg);
					this.$refs.gameScreen.killDeathMsg();
				},
				challengeMsg(msg) {
					// Add the new message
					this.game.challengeMsg.msgs.push(msg);

					// Remove duplicates: Convert the array to a Set and back to an array
					this.game.challengeMsg.msgs = [...new Set(this.game.challengeMsg.msgs)];

					// Proceed with displaying the message if not already showing
					if (!this.game.challengeMsg.showing) {
						this.$refs.gameScreen.challengeMsg();
					}
				},
				ctsCapturedMsg(msg) {
					this.game.ctsMsg.team = msg.team;
					this.game.ctsMsg.msg = msg.msg;
					
					this.$refs.gameScreen.ctsCapturedMsg();
				},

				shellStreakMsg(msg) {
					if (msg.streak > 1 && (msg.streak > this.game.streakMsg.count)) {
						this.$refs.gameScreen.gameScreenStreakAction();
					}
					this.game.streakMsg.count = msg.streak;
					this.game.streakMsg.msg = msg.msg;
				},

				bestStreakUpdate(streak) {
					const hasInc = streak > this.game.bestStreak.count ? true : false;
					this.game.bestStreak.count = streak;
					if (hasInc) {
						this.$refs.gameScreen.bestStreakUpdate();
					}

				},

				shellIngameNotification(item) {
					this.game.ingameNotification.item = item;
					this.$refs.gameScreen.ingameNotification();
				},
			},
			computed: {
				appClassObj() {
					return {
						'playing-crazy-games': crazyGamesActive,
						'is-vip': this.isSubscriber && this.isUpgraded ? true : false,
						'is-paused': this.game.isPaused && this.game.on && this.showScreen === this.screens.game,
					}
				},

				appClassScreen() {
					return getKeyByValue(this.screens, this.showScreen) + '-screen';
				},

				isPhotoBooth() {
					return !this.ui.showHomeEquipUi ? 'photo-booth' : '';
				},

				bigBannerAdLink() {
					return this.bigHouseAd.link
				},
				bigBannerAdImg() {
					return dynamicContentPrefix + `data/img/art/${this.bigHouseAd.id}${this.bigHouseAd.imageExt}`;
				},
				showEquipScreens() {
					return this.showScreen === this.screens.equip || this.showScreen === this.screens.featured || this.showScreen === this.screens.gear || this.showScreen === this.screens.limited;
				},
				
				accountStatus() {
					if (this.isAnonymous) {
						return this.isAnonymous && hasValue(this.firebaseId) ? 'anon' : 'no-account';
					} else {
						return hasValue(this.firebaseId) ? 'signed-in' : 'no-account';
					}
				},
				chwClass() {
					if (this.chw.limitReached || this.isChicknWinnerError) {
						return 'grid-column-1-eq';
					} else {
							return 'grid-column-1-eq';
					}
				},
				chwHomeTimerCls() {
					if (this.chw.limitReached) {
						return 'chw-home-screen-max-watched';
					} else {
						if (this.chw.ready) {
							return 'is-ready active';
						} else {
							return 'not-ready';
						}
					}
				},
				chwChickSrc() {
					if (this.chw.limitReached || this.isChicknWinnerError) {
						// return 'img/chicken-nugget/chickLoop_daily_limit.svg';
						return this.chw.imgs.limit;
					} else {
						if (!this.chw.ready) {
							// return 'img/chicken-nugget/chickLoop_sleep.svg';
							return this.chw.imgs.sleep;
						} else {
							// return 'img/chicken-nugget/chickLoop_speak.svg';
							return this.chw.imgs.speak;
						}
					}
				},
				chwShowTimer() {
					return true;
					if (this.chw.limitReached) {
						// this.chwStopCycle();
						return false;
					} else {
						if (this.chw.ready) {
							this.chwShowCycle();
							return false;
						} else {
							// this.chwStopCycle();
							return true;
						}
					}
				},
				remainingMsg() {
					const { adBlockDetect, ready, limitReached, winnerCounter } = this.chw;
					const { chw_error_text, chw_cooldown_msg, chw_ready_msg, chw_time_until, chw_daily_limit_msg } = this.loc;

					if (adBlockDetect) {
						return 'Please turn off ad blocker';
					}

					if (this.isChicknWinnerError) {
						return chw_error_text;
					}

					if (limitReached) {
						return chw_daily_limit_msg;
					}

					if (ready) {
						return winnerCounter > 0 ? chw_cooldown_msg : chw_ready_msg;
					} 

					return chw_time_until;
				},
				progressBarWrapClass() {
					if (this.chw.ready && !this.chw.limitReached) {
						return 'chw-progress-bar-wrap-complete';
					}
				},
				playAdText() {
					if (this.chw.limitReached) {
						return `<i class="fas fa-egg"></i> ${200 * (this.chw.resets + 1)} Wake Now!`;
					} else {
						return this.loc.chw_btn_free_reward;
					}
				},
				isEggStoreSaleItem() {
					return this.eggStoreItems.some( item => item['salePrice'] !== '');
				},
				footerLinksFormat() {
					let link = ['https://badegg.io/?utm_source=shellshock_homepage&utm_medium=referral', 'https://basketbros.io/?utm_source=shellshock_homepage&utm_medium=referral', 'https://wrestlebros.io/?utm_source=shellshock_homepage&utm_medium=referral', 'https://www.crazygames.com/game/bad-egg', 'https://www.crazygames.com/game/basketbros', 'https://www.crazygames.com/game/wrestle-bros'];
					if (!crazyGamesActive) {
						return this.loc.home_desc_p7.format(link[0], link[1], link[2]);
					} else {
						return this.loc.home_desc_p7.format(link[3], link[4], link[5]);
					}
				},
				anonPopupContent() {
					return this.loc.account_anon_warn_paragraph_block.format('<img src="img/svg/ico_goldenEgg.svg" class="egg_icon" />');
				},
				chwShowBtn() {
					//chw.ready && !chw.adBlockDetect"
					if ((this.chw.ready && !this.chw.limitReached && !this.chw.adBlockDetect) || (!this.chw.ready && this.chw.limitReached && !this.chw.adBlockDetect)) {
						return true;
					} else {
						return false;

					}
				},
				abTestText() {
					const idx = Math.max(this.abTestInventory.currentIdx - 1, 0);
					let setting = '';

					if (this.abTestInventory.clickables[idx].setting) {
						setting = vueApp.settingsUi.controls.keyboard.game.find(item => item.id === this.abTestInventory.clickables[idx].setting).value;
					}
					let text = this.loc[this.abTestInventory.clickables[idx].locKey];

					if (text) {
						return this.loc[this.abTestInventory.clickables[idx].locKey].format(setting);
					}
				},
				loginPopupWarningTxt(){
					return this.loc.sign_in_and_leave_game;
				}
			},
			watch : {
				loc(val) {
					this.getLocLang(val);
				},
				firebaseId(val) {
					if (val && this.chwSignInClicked) {
						vueApp.showChicknWinnerPopup();
						this.chwSignInClicked = false;
					}
				}
			}
		});
	}
</script>

		<div id="ad-block-test" class="adsbygoogle"></div>
		<div id="ublock-test" style="display:none;">
	<script defer src="https://static.cloudflareinsights.com/beacon.min.js/vcd15cbe7772f49c399c6a5babf22c1241717689176015" integrity="sha512-ZpsOmlRQV6y907TI0dKBHq9Md29nnaEIPlkf84rnaERnq6zvWvPUqr2ft8M1aS28oN72PdrCzSjY4U6VaAw1EQ==" data-cf-beacon='{"rayId":"8f2eeba32e1addb4","serverTiming":{"name":{"cfExtPri":true,"cfL4":true,"cfSpeedBrain":true,"cfCacheStatus":true}},"version":"2024.10.5","token":"b4cd973aeca34b509bef2ed0c9e0b720"}' crossorigin="anonymous"></script>
</body>
</html>