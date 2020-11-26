import Hammer from "hammerjs";
import queryString from "query-string";

const BREAKPOINT = 900;

export default class Tooltip {
  constructor(
    /* the images to create a carousel from */
    images
  ) {
    Object.assign(this, {
      images: images.sort((a, b) => {
        return (
          Number(a.getAttribute("data-carousel-index")) -
          Number(b.getAttribute("data-carousel-index"))
        );
      }),
      primaryImage: null,
      wrapper: null,
      slider: null,
      dots: null,
      currentIndex: 0,
      carouselInitialized: null,
      imageLocations: images.map((i) => ({
        element: i.previousElementSibling || i.parentElement,
        type: i.previousElementSibling ? "sibling" : "parent",
      })),
    });

    this.set();
    window.addEventListener("resize", this.set.bind(this));
  }

  set() {
    const mediaQuery = window.matchMedia(`(max-width: ${BREAKPOINT}px)`);
    const qs = queryString.parse(window.location.search);
    const isMobile = mediaQuery.matches && !qs.desktop;
    if (isMobile && !this.carouselInitialized) {
      return this.initCarousel(this.images);
    } else if (!mediaQuery.matches && this.carouselInitialized === true) {
      return this.tearDownCarousel();
    }
  }

  moveForward() {
    if (this.currentIndex + 1 === this.images.length) return this.cancelMove();
    this.currentIndex += 1;
    const transform = this.currentIndex * window.innerWidth;
    this.slider.style.transform = `translateX(-${transform}px)`;
    this.updateDots();
  }

  moveBackward() {
    if (this.currentIndex === 0) return this.cancelMove();
    this.currentIndex -= 1;
    const transform = this.currentIndex * window.innerWidth;
    this.slider.style.transform = `translateX(-${transform}px)`;
    this.updateDots();
  }

  cancelMove() {
    const transform = this.currentIndex * window.innerWidth;
    this.slider.style.transform = `translateX(-${transform}px)`;
    this.updateDots();
  }

  updateDots() {
    const dots = this.dots.children;
    [...dots].forEach((dot) => dot.classList.remove("carousel__dot--selected"));
    dots[this.currentIndex].classList.add("carousel__dot--selected");
  }

  initCarousel(images) {
    this.carouselLocation = document.querySelector("[data-carousel-location]");
    this.wrapper = document.createElement("div");
    this.wrapper.classList.add("carousel");
    this.slider = document.createElement("div");
    this.slider.classList.add("carousel__slider");
    this.dots = document.createElement("div");
    this.dots.classList.add("carousel__dots");

    this.carouselLocation.prepend(this.wrapper);
    this.wrapper.appendChild(this.slider);
    this.wrapper.appendChild(this.dots);

    this.images.forEach((image, index) => {
      this.slider.appendChild(image);

      if (this.images.length <= 1) return;

      const dotNode = document.createElement("div");
      dotNode.classList.add("carousel__dot");
      if (index === 0) dotNode.classList.add("carousel__dot--selected");
      this.dots.appendChild(dotNode);
    });

    this.carouselInitialized = true;

    if (this.images.length === 1) return;

    this.hammer = new Hammer(this.wrapper);

    this.hammer.on("pan", (ev) => {
      if (!(ev.direction === 2 || ev.direction === 4)) return;
      if (ev.angle > -150 && ev.angle < -100) return;
      const transform = this.currentIndex * window.innerWidth;
      this.slider.style.transform = `translateX(-${transform - ev.deltaX}px)`;
    });

    this.hammer.on(
      "panend",
      function (ev) {
        const { deltaTime, deltaX, direction } = ev;
        const threshold = window.innerWidth / 2;

        //fast momentum
        if (deltaTime < 1000) {
          if (deltaX < (threshold / 4) * -1) return this.moveForward();
          if (deltaX > threshold / 4) return this.moveBackward();
        }

        if (deltaTime > 1000) {
          //slow momentum
          if (deltaX < threshold * -1) return this.moveForward();
          if (deltaX > threshold * 1) return this.moveBackward();
        }

        //otherwise, return
        this.cancelMove();
      }.bind(this)
    );
  }

  tearDownCarousel() {
    this.carouselLocation = null;
    this.wrapper.remove();
    this.slider.remove();
    this.dots.remove();
    this.hammer.off("pan");
    this.hammer.off("panend");

    this.images.forEach((image, index) => {
      const { type, element } = this.imageLocations[index];
      return type === "sibling" ? element.after(image) : element.prepend(image);
    });
  }
}
