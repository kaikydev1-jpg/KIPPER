// Kipper — site: idioma (português/inglês), sugestão do arquivo certo e copiar o comando.
(() => {
  "use strict";

  // Jeitos de apoiar o projeto. Vazio = a seção "Apoiar" e o link do menu não aparecem.
  // pix: a chave Pix (de preferência a chave aleatória). sponsors: https://github.com/sponsors/<usuário>,
  // só depois que o GitHub aprovar o perfil (antes disso a página não aceita apoio).
  const APOIO = { pix: "", sponsors: "" };

  const EN = {
    "skip": "Skip to content",
    "nav.features": "Features",
    "nav.3d": "3D",
    "nav.who": "Everything it does",
    "nav.download": "Download",
    "nav.support": "Support",
    "hero.eyebrow": "Free · Open source · Windows and Linux",
    "hero.eyebrow.android": "Free · Open source · Windows, Linux and Android",
    "hero.title": "Edit video from the first cut <em>to a whole film.</em>",
    "hero.lede": "Kipper is a complete video editor with no watermark, no account and no subscription. Easy when you are starting out, with everything people who already edit need.",
    "hero.cta": "Download Kipper",
    "hero.source": "View the code on GitHub",
    "hero.hint": "Windows 10 and 11 · Fedora · Ubuntu · Matsu OS · any Linux",
    "hero.hint.android": "Windows 10 and 11 · Fedora · Ubuntu · Matsu OS · any Linux · Android phones",
    "facts.free.t": "Actually free",
    "facts.free.d": "No watermark and no hidden paid plan.",
    "facts.local.t": "All on your computer",
    "facts.local.d": "Nothing is uploaded. No telemetry.",
    "facts.open.t": "Open source",
    "facts.open.d": "GPLv3 licence. Anyone can check it.",
    "facts.lang.t": "In your language",
    "facts.lang.d": "English and Brazilian Portuguese.",
    "features.title": "What you can do",
    "features.lede": "The features of a professional editor, laid out so they stay out of the way when you only want to cut and post.",
    "vertical.title": "Vertical video, done right",
    "vertical.text": "A 9:16 project for Reels, TikTok and Shorts? The preview stands up beside the timeline and the rest of the screen fits around it. Go back to 16:9 and the editor follows.",
    "vertical.t1": "Ready-made formats: Reels, TikTok, Shorts, Stories, YouTube",
    "vertical.t2": "Reframing that follows the face",
    "vertical.t3": "Automatic captions at the right size",
    "f.captions.t": "Automatic captions",
    "f.captions.d": "Speech becomes text on your own computer. Cut phrases, drop the fillers and style everything at once.",
    "f.color.t": "Color grading",
    "f.color.d": "Shadow, midtone and highlight wheels, curves, HSL and .cube LUTs, with histogram and vectorscope.",
    "f.keys.t": "Keyframes and curves",
    "f.keys.d": "Animate position, scale, rotation, opacity and any effect, with a curve editor.",
    "f.track.t": "Masks that follow",
    "f.track.d": "Point and planar tracking, blur and pixelate any area, cut people out of the shot.",
    "f.audio.t": "Audio that sounds finished",
    "f.audio.d": "Voice cleanup, loudness meter, EQ, compressor and voiceover recorded from the mic.",
    "f.fx.t": "28 transitions and 71 effects",
    "f.fx.d": "All previewed on your own footage before you apply them. And you can make your own.",
    "f.timeline.t": "A timeline that behaves",
    "f.timeline.d": "Multiple tracks, ripple edits, snapping, freeze frame, speed and markers.",
    "f.export.t": "Exports up to 4K",
    "f.export.d": "MP4, GIF or audio only, the whole video or a range. The preview is exactly what you get.",
    "lv1.i1": "Ready-made projects for Reels, TikTok, Shorts, Stories and YouTube (9:16, 16:9 and 1:1)",
    "lv1.i2": "Drag in videos, photos and music; trim, split, delete and reorder",
    "lv1.i3": "Automatic captions from speech, on your own computer",
    "lv1.i4": "Text with 35 ready-made styles, stickers, emoji and shapes",
    "lv1.i5": "28 transitions and 71 effects, previewed on your own footage",
    "lv1.i6": "Music, volume and smooth fade in and out",
    "lv1.i7": "Speed, slow motion, reverse and freeze frame",
    "lv1.i8": "Crop, reframe and a colour or image background",
    "lv1.i9": "Export MP4 up to 4K, a GIF or the audio only",
    "lv1.i10": "On Android phones, the same CapCut-style editor",
    "lv1.tag": "Starting out",
    "lv1.t": "Cut, caption and post",
    "lv2.i1": "Keyframes on position, scale, rotation, opacity and effects, with curves",
    "lv2.i2": "Text animation and styled titles",
    "lv2.i3": "Colour: wheels, curves, HSL and .cube LUTs, with histogram, waveform, parade and vectorscope",
    "lv2.i4": "Shape and brush masks; blur or pixelate an area",
    "lv2.i5": "Cut people out of the background without a green screen",
    "lv2.i6": "Stabilize shaky video, all the way to a tripod look",
    "lv2.i7": "31 audio effects, voice cleanup, loudness meter and silence removal",
    "lv2.i8": "Fun voices: robot, chipmunk, deep voice, telephone, megaphone, underwater",
    "lv2.i9": "Record a voiceover from the mic, or generate one from a script",
    "lv2.i10": "Beat markers and effects in time with the music",
    "lv2.i11": "Blend modes and adjustment layers",
    "lv2.tag": "Intermediate",
    "lv2.t": "Make it look finished",
    "lv3.i1": "12 workspaces: editing, vertical, audio, recording, captions, AI, colour, keyframes, masking and tracking, 3D and procedural",
    "lv3.i2": "Point and planar tracking (up to 4 points, with perspective) and masks that follow the subject",
    "lv3.i3": "AI object cutout: click the subject and it is cut out through the whole clip",
    "lv3.i4": "Multicam, synced by sound, switching angles as it plays",
    "lv3.i5": "Speed curves (ramps)",
    "lv3.i6": "Find the scenes in a long video, each shot ranked by motion and loudness",
    "lv3.i7": "Enhance video: AI upscaling",
    "lv3.i8": "Proxies to edit 4K smoothly",
    "lv3.i9": "Lottie and SVG animations",
    "lv3.i10": "Your own effects and transitions in GLSL",
    "lv3.i11": "H.264, H.265, AV1 and VP9 with transparency, with NVIDIA, Intel and AMD acceleration",
    "lv3.i12": "Projects saved with their media, autosave and recovery after a crash",
    "lv3.tag": "Advanced",
    "lv3.t": "Make a film",
    "d3.i1": "3D models (.glb) on the timeline, with their own animations",
    "d3.i2": "Captured Gaussian splat scenes (.ply and .sog)",
    "d3.i3": "Any clip becomes a 3D layer: position, rotation and scale in 3D, with perspective",
    "d3.i4": "Up to 4 lights per model, coloured and keyframable",
    "d3.i5": "3D layers that hide behind each other by depth",
    "d3.i6": "A scene camera, with camera cuts and a point of interest",
    "d3.i7": "A free 3D view you navigate like Blender or Maya, with grid, snapping and an outliner",
    "d3.i8": "AI depth estimation for depth effects on ordinary video",
    "d3.i9": "3D props that follow a face",
    "d3.i10": "Procedural 3D scenes built from code (Lua and GLSL shaders)",
    "all.title": "Everything Kipper does",
    "all.lede": "The same program grows with you: start with the basics and find the rest when you need it.",
    "all.note": "Automatic captions, people and object cutout, voice from text, video enhancement, depth and scene finding run on your own computer. The first time, each one downloads its add-on from Extras.",
    "d3.title": "3D inside the editor",
    "d3.text": "No second program needed: models, lights, camera and depth live on the same timeline as your video, with keyframes like any other clip. There is even a workspace just for 3D.",
    "dl.title": "Download Kipper",
    "dl.lede": "On Linux the easiest way is this command: it finds out your system, downloads the right file, checks it and installs it.",
    "dl.copy": "Copy",
    "dl.copied": "Copied",
    "dl.get": "Download",
    "dl.win": "Windows 10 and 11. Installs for your user only, without asking for administrator.",
    "dl.matsu": "Opens with the Matsu OS look already applied.",
    "dl.fedora": "Open the file and install it from your software store, or use <code>sudo dnf install ./Kipper-Fedora.rpm</code>.",
    "dl.atomic": "Silverblue, Kinoite and friends: through Flatpak, without touching the system.",
    "dl.debian": "Also Linux Mint, Pop!_OS and Zorin. Or <code>sudo apt install ./Kipper-Ubuntu-Debian.deb</code>.",
    "dl.other.t": "Other Linux",
    "dl.debian.t": "Ubuntu and Debian",
    "dl.other": "The AppImage runs on any Linux without installing. Flatpak works on any distro that has it.",
    "dl.sums": "Every file and its SHA-256 checksum is on the <a href=\"https://github.com/kaikydev1-jpg/KIPPER/releases\">GitHub releases page</a>.",
    "dl.suggested": "For you",
    "dl.android": "For phones. Download it straight from your phone's browser and open the file; the first time, Android asks you to allow installing apps downloaded by it. After that, Kipper tells you about new versions and updates itself.",
    "dl.android32": "Older phone (32-bit)",
    "sup.title": "Support Kipper",
    "sup.lede": "Kipper is free and will stay free, with no ads and no paid plan. If it helped you, any amount helps keep the project going.",
    "sup.pix": "For people in Brazil: instant and free. Copy the key and paste it in your bank app.",
    "sup.sponsors": "From any country, with a credit or debit card, once or every month. Needs a GitHub account; the whole amount goes to the project.",
    "sup.give": "Support on GitHub",
    "footer.credits": "Free software under the GPLv3 licence. Based on <a href=\"https://github.com/CutWire-Studios/Drift\" rel=\"noopener\">Drift</a> by CutWire Studios, with design ideas from <a href=\"https://github.com/jub0t/Concat\" rel=\"noopener\">Concat</a>.",
    "footer.media": "Sample footage in the screenshots: <a href=\"https://images.nasa.gov/\" rel=\"noopener\">NASA</a> (public domain). Sample 3D model: BoxAnimated, © Cesium, <a href=\"https://creativecommons.org/licenses/by/4.0/\" rel=\"noopener\">CC BY 4.0</a> (<a href=\"https://github.com/KhronosGroup/glTF-Sample-Assets\" rel=\"noopener\">Khronos glTF Sample Assets</a>).",
    "footer.source": "Source code",
    "footer.issues": "Report a problem"
  };
  const PT_EXTRA = {
    "dl.copied": "Copiado", "dl.suggested": "Para você", "dl.copy": "Copiar",
    // Só quando a versão publicada tem o APK.
    "hero.eyebrow.android": "Grátis · Código aberto · Windows, Linux e Android",
    "hero.hint.android": "Windows 10 e 11 · Fedora · Ubuntu · Matsu OS · qualquer Linux · celular Android"
  };

  // Guarda o texto em português que já está na página, para voltar a ele.
  const PT = {};
  document.querySelectorAll("[data-i18n]").forEach((el) => { PT[el.dataset.i18n] = el.textContent; });
  document.querySelectorAll("[data-i18n-html]").forEach((el) => { PT[el.dataset.i18nHtml] = el.innerHTML; });
  Object.assign(PT, PT_EXTRA);

  let lang = "pt";
  // Versão mais nova publicada no GitHub (preenchida mais abaixo; null até chegar).
  let latest = null;
  const t = (key) => (lang === "en" ? EN : PT)[key] ?? PT[key] ?? key;

  function applyLanguage(next) {
    lang = next;
    document.documentElement.lang = lang === "en" ? "en" : "pt-BR";
    document.querySelectorAll("[data-i18n]").forEach((el) => { el.textContent = t(el.dataset.i18n); });
    document.querySelectorAll("[data-i18n-html]").forEach((el) => { el.innerHTML = t(el.dataset.i18nHtml); });
    const toggle = document.getElementById("lang-toggle");
    toggle.textContent = lang === "en" ? "PT" : "EN";
    toggle.setAttribute("aria-label", lang === "en" ? "Mudar idioma para português" : "Switch language to English");
    document.querySelectorAll(".system.suggested h3").forEach((el) => el.setAttribute("data-suggested", t("dl.suggested")));
    try { localStorage.setItem("kipper-lang", lang); } catch (_) { /* sem armazenamento: tudo bem */ }
    renderVersion();
  }

  let saved = null;
  try { saved = localStorage.getItem("kipper-lang"); } catch (_) { saved = null; }
  const browserIsEnglish = (navigator.language || "").toLowerCase().startsWith("en");
  applyLanguage(saved || (browserIsEnglish ? "en" : "pt"));
  document.getElementById("lang-toggle").addEventListener("click", () => applyLanguage(lang === "en" ? "pt" : "en"));

  // Sugere o arquivo do sistema de quem está visitando (o navegador só diz Windows ou Linux).
  const ua = navigator.userAgent || "";
  const platform = (navigator.userAgentData && navigator.userAgentData.platform) || navigator.platform || "";
  let os = null;
  if (/Android/i.test(ua)) os = "android";
  else if (/Windows/i.test(ua) || /Win/i.test(platform)) os = "windows";
  else if (/Fedora/i.test(ua)) os = "fedora";
  else if (/Ubuntu|Debian|Mint/i.test(ua)) os = "debian";
  else if (/Linux/i.test(ua) && !/Android/i.test(ua)) os = "linux";
  function suggest() {
    if (!os) return;
    const card = document.querySelector(`.system[data-os="${os}"]`);
    if (card && !card.hidden) {
      card.classList.add("suggested");
      card.querySelector("h3").setAttribute("data-suggested", t("dl.suggested"));
    }
  }
  suggest();

  // Versão atual: lida da lista pública de versões do GitHub, então o site acompanha cada versão
  // publicada sem precisar ser mexido. Sem resposta (sem internet, limite do GitHub), a linha some.
  function renderVersion() {
    const el = document.getElementById("versao-atual");
    if (!el || !latest) return;
    const when = new Date(latest.published_at);
    const date = isNaN(when) ? "" : when.toLocaleDateString(lang === "en" ? "en-US" : "pt-BR",
                                                             { day: "numeric", month: "long", year: "numeric" });
    const version = latest.tag_name.replace(/^v/, "");
    el.textContent = lang === "en"
      ? `Current version: ${version}${date ? " · released " + date : ""}`
      : `Versão atual: ${version}${date ? " · publicada em " + date : ""}`;
    el.hidden = false;
  }
  fetch("https://api.github.com/repos/kaikydev1-jpg/KIPPER/releases/latest", { headers: { Accept: "application/vnd.github+json" } })
    .then((r) => (r.ok ? r.json() : null))
    .then((data) => {
      if (!data || !data.tag_name) return;
      latest = data;
      renderVersion();
      // O cartão do Android só aparece quando a versão publicada tem o APK.
      const names = (data.assets || []).map((a) => a.name);
      if (names.includes("Kipper-Android.apk")) {
        document.getElementById("card-android").hidden = false;
        document.querySelectorAll("[data-android]").forEach((el) => { el.hidden = false; });
        document.getElementById("hero-eyebrow").dataset.i18n = "hero.eyebrow.android";
        document.getElementById("cta-hint").dataset.i18n = "hero.hint.android";
        applyLanguage(lang);
        if (!names.includes("Kipper-Android-32bits.apk"))
          document.querySelector('#card-android .btn-ghost').hidden = true;
        suggest();
        // No celular, o botão principal do topo já baixa o APK.
        if (os === "android") {
          document.getElementById("cta-download").href =
            "https://github.com/kaikydev1-jpg/KIPPER/releases/latest/download/Kipper-Android.apk";
        }
      }
    })
    .catch(() => { /* sem a versão, o resto do site funciona igual */ });

  // Apoiar: só o que estiver configurado em APOIO aparece.
  if (APOIO.pix || APOIO.sponsors) {
    document.getElementById("apoiar").hidden = false;
    document.querySelector(".nav-support").hidden = false;
    if (APOIO.pix) {
      document.getElementById("pix-key").textContent = APOIO.pix;
      document.getElementById("way-pix").hidden = false;
    }
    if (APOIO.sponsors && /^https:\/\/github\.com\/sponsors\/[A-Za-z0-9-]+\/?$/.test(APOIO.sponsors)) {
      document.getElementById("sponsors-link").href = APOIO.sponsors;
      document.getElementById("way-sponsors").hidden = false;
    }
  }

  // Copiar o comando do terminal (e a chave Pix), com o visto se desenhando.
  setupCopy(document.getElementById("copy-cmd"), document.getElementById("install-cmd"));
  setupCopy(document.getElementById("copy-pix"), document.getElementById("pix-key"));

  function setupCopy(copyBtn, cmd) {
    copyBtn.addEventListener("click", async () => {
      const text = cmd.textContent.trim();
      let ok = false;
      try {
        await navigator.clipboard.writeText(text);
        ok = true;
      } catch (_) {
        const range = document.createRange();
        range.selectNodeContents(cmd);
        const sel = window.getSelection();
        sel.removeAllRanges();
        sel.addRange(range);
        try { ok = document.execCommand("copy"); } catch (__) { ok = false; }
        sel.removeAllRanges();
      }
      if (!ok) return;
      const label = copyBtn.querySelector("span");
      copyBtn.classList.add("done");
      label.textContent = t("dl.copied");
      setTimeout(() => {
        copyBtn.classList.remove("done");
        label.textContent = t("dl.copy");
      }, 1800);
    });
  }
})();
