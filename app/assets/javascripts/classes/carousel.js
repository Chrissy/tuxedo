import Hammer from "hammerjs";

const BREAKPOINT = 900;

export default class Tooltip {
  constructor(
    /* the images to create a carousel from */
    images
  ) {
    Object.assign(this, {
      images,
      primaryImage: null,
      wrapper: null,
      slider: null,
      currentIndex: 0,
    });

    const mediaQuery = window.matchMedia(`(max-width: ${BREAKPOINT}px)`);
    if (mediaQuery.matches) this.initCarousel(images);
  }

  moveForward() {
    if (this.currentIndex + 1 === this.images.length) return;
    this.currentIndex += 1;
    const transform = this.currentIndex * window.innerWidth;
    this.slider.style.transform = `translateX(-${transform}px)`;
  }

  moveBackward() {
    if (this.currentIndex === 0) return;
    this.currentIndex -= 1;
    const transform = this.currentIndex * window.innerWidth;
    this.slider.style.transform = `translateX(-${transform}px)`;
  }

  initCarousel(images) {
    this.primaryImage = images[0];
    this.wrapper = document.createElement("div");
    this.wrapper.classList.add("carousel");
    this.slider = document.createElement("div");
    this.slider.classList.add("slider");
    this.primaryImage.after(this.wrapper);
    this.wrapper.appendChild(this.slider);
    this.images.forEach((image, index) => {
      this.slider.appendChild(image);
      const dotNode = document.createElement("div");
      dotNode.classList.add("carousel__dot");
      if (index === 0) dotNode.classList.add("carousel__dot--selected");
      this.wrapper.appendChild(dotNode);
    });

    var hammer = new Hammer(this.wrapper);
    hammer.on(
      "swipe",
      function (ev) {
        if (ev.direction === 2) this.moveForward();
        if (ev.direction === 4) this.moveBackward();
      }.bind(this)
    );
  }
}
