const PercyScript = require("@percy/script");

const PORT = process.env.PORT_NUMBER || 3000;
const DESKTOP_WIDTHS = [1400, 1200, 1024];
const MOBILE_WIDTHS = [375, 411];
const WIDTHS = [...DESKTOP_WIDTHS, ...MOBILE_WIDTHS];
const URL = "http://localhost";

const navigateTo = async (path, page) => {
  await page.goto(`${URL}:${PORT}${path}`);
  //await page.waitForSelector(".js-ready");
  return page;
};

PercyScript.run(async (page, percySnapshot) => {
  await navigateTo("/", page);
  await percySnapshot("Homepage", { widths: WIDTHS });

  await navigateTo("/odd-bedfellows-cocktail-recipe?desktop=true", page);

  await percySnapshot("Two-up Recipe Desktop", { widths: DESKTOP_WIDTHS });

  await navigateTo("/odd-bedfellows-cocktail-recipe", page);
  await percySnapshot("Two-up Recipe Mobile", { widths: MOBILE_WIDTHS });

  await navigateTo("/spanish-coffee-cocktail-recipe?desktop=true", page);
  await percySnapshot("Three-up Cocktail Desktop", { widths: DESKTOP_WIDTHS });

  await navigateTo("/spanish-coffee-cocktail-recipe", page);
  await percySnapshot("Three-up Cocktail Mobile", { widths: MOBILE_WIDTHS });

  await navigateTo("/fionia-cocktail-recipe?desktop=true", page);
  await percySnapshot("One-up Cocktail Desktop", { widths: DESKTOP_WIDTHS });

  await navigateTo("/fionia-cocktail-recipe", page);
  await percySnapshot("One-up Cocktail Mobile", { widths: MOBILE_WIDTHS });

  await navigateTo("/tags/cocktail-glass", page);
  await percySnapshot("Tag", { widths: WIDTHS });

  await navigateTo("/ingredients/sherry-cocktail-recipes?desktop=true", page);
  await percySnapshot("Simple Ingredient Desktop", { widths: DESKTOP_WIDTHS });

  await navigateTo("/ingredients/sherry-cocktail-recipes", page);
  await percySnapshot("Simple Ingredient Mobile", { widths: MOBILE_WIDTHS });

  await navigateTo(
    "/ingredients/peychaud-s-bitters-cocktail-recipes?desktop=true",
    page
  );
  await percySnapshot("Complex Ingredient Desktop", { widths: DESKTOP_WIDTHS });

  await navigateTo("/ingredients/peychaud-s-bitters-cocktail-recipes", page);
  await percySnapshot("Complex Ingredient Mobile", { widths: MOBILE_WIDTHS });

  await navigateTo("/recipes", page);
  await percySnapshot("Index", { widths: WIDTHS });

  await navigateTo("/about", page);
  await percySnapshot("About", { widths: WIDTHS });
});
