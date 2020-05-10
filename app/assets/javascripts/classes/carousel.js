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
    });

    const mediaQuery = window.matchMedia(`(max-width: ${BREAKPOINT}px)`);
    if (mediaQuery.matches) this.initCarousel(images);
  }

  initCarousel(images) {
    this.primaryImage = images[0];
    this.wrapper = document.createElement("div");
    this.wrapper.classList.add("carousel");
    this.primaryImage.after(this.wrapper);
    this.images.forEach((image, index) => {
      this.wrapper.appendChild(image);
      const dotNode = document.createElement("div");
      dotNode.classList.add("carousel__dot");
      if (index === 0) dotNode.classList.add("carousel__dot--selected");
      this.wrapper.appendChild(dotNode);
    });
  }
}
