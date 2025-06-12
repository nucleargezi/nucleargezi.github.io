// initial
const locales = document.querySelectorAll(".locale-switch");
{
  const explicitLang = localStorage.getItem("explicitLang");
  if (explicitLang) {
    document.documentElement.lang = explicitLang;
    document.documentElement.classList.add("lang-active");
    locales.forEach((el) => {
      if (el.innerText === explicitLang) {
        el.classList.add("active");
      } else {
        el.classList.remove("active");
      }
    });
  }
}

locales.forEach((el) => {
  el.addEventListener("click", () => {
    const isActive = el.classList.contains("active");
    for (const e of locales) {
      if (e.innerText === el.innerText) {
        e.classList.toggle("active");
      } else {
        e.classList.remove("active");
      }
    }

    if (!isActive) {
      document.documentElement.lang = el.innerText;
      document.documentElement.classList.add("lang-active");

      localStorage.setItem("explicitLang", el.innerText);
    } else {
      document.documentElement.lang = "en";
      document.documentElement.classList.remove("lang-active");

      localStorage.removeItem("explicitLang");
    }
  });
});
