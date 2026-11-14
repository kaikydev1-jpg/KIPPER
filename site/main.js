// Kipper — site: idioma (português/inglês), sugestão do arquivo certo e copiar o comando.
(() => {
  "use strict";

  const EN = {
    "skip": "Skip to content",
    "nav.features": "Features",
    "nav.who": "Who it's for",
    "nav.download": "Download",
    "hero.eyebrow": "Free · Open source · Windows and Linux",
    "hero.title": "Edit video from the first cut <em>to a whole film.</em>",
    "hero.lede": "Kipper is a complete video editor with no watermark, no account and no subscription. Easy when you are starting out, with everything people who already edit need.",
    "hero.cta": "Download Kipper",
    "hero.source": "View the code on GitHub",
    "hero.hint": "Windows 10 and 11 · Fedora · Ubuntu · Matsu OS · any Linux",
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
    "f.audio.d": "Voice cleanup, loudness meter, EQ, recorded voiceover and music that ducks under speech.",
    "f.fx.t": "Over 150 transitions",
    "f.fx.d": "And dozens of effects, all previewed on your own footage before you apply them.",
    "f.timeline.t": "A timeline that behaves",
    "f.timeline.d": "Multiple tracks, ripple edits, snapping, freeze frame, speed and markers.",
    "f.export.t": "Exports up to 4K",
    "f.export.d": "MP4, GIF or audio only, the whole video or a range. The preview is exactly what you get.",
    "who.title": "For people starting out, and people who already edit",
    "who.lede": "The same program grows with you.",
    "who.l1.tag": "Starting out",
    "who.l1.t": "Cut, caption and post",
    "who.l1.d": "Drop the video in, cut what you don't need, generate captions and export in the social network's format.",
    "who.l2.tag": "Intermediate",
    "who.l2.t": "Make it look finished",
    "who.l2.d": "Transitions, styled titles, music on the beat, corrected color and clean audio.",
    "who.l3.tag": "Advanced",
    "who.l3.t": "Make a film",
    "who.l3.d": "Workspaces for color, audio and masking, multicam, 3D on the timeline and proxies for 4K.",
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
    "footer.credits": "Free software under the GPLv3 licence. Based on <a href=\"https://github.com/CutWire-Studios/Drift\" rel=\"noopener\">Drift</a> by CutWire Studios, with design ideas from <a href=\"https://github.com/jub0t/Concat\" rel=\"noopener\">Concat</a>.",
    "footer.media": "Sample footage in the screenshots: <a href=\"https://images.nasa.gov/\" rel=\"noopener\">NASA</a> (public domain).",
    "footer.source": "Source code",
    "footer.issues": "Report a problem"
  };
  const PT_EXTRA = { "dl.copied": "Copiado", "dl.suggested": "Para você", "dl.copy": "Copiar" };

  // Guarda o texto em português que já está na página, para voltar a ele.
  const PT = {};
  document.querySelectorAll("[data-i18n]").forEach((el) => { PT[el.dataset.i18n] = el.textContent; });
  document.querySelectorAll("[data-i18n-html]").forEach((el) => { PT[el.dataset.i18nHtml] = el.innerHTML; });
  Object.assign(PT, PT_EXTRA);

  let lang = "pt";
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
  if (/Windows/i.test(ua) || /Win/i.test(platform)) os = "windows";
  else if (/Fedora/i.test(ua)) os = "fedora";
  else if (/Ubuntu|Debian|Mint/i.test(ua)) os = "debian";
  else if (/Linux/i.test(ua) && !/Android/i.test(ua)) os = "linux";
  if (os) {
    const card = document.querySelector(`.system[data-os="${os}"]`);
    if (card) {
      card.classList.add("suggested");
      card.querySelector("h3").setAttribute("data-suggested", t("dl.suggested"));
    }
  }

  // Copiar o comando do terminal, com o visto se desenhando.
  const copyBtn = document.getElementById("copy-cmd");
  const cmd = document.getElementById("install-cmd");
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
})();
