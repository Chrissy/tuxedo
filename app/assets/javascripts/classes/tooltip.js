import { createPopper } from "@popperjs/core";
import { debounce } from "throttle-debounce";

export default class Tooltip {
  constructor({
    /* the target to watch for events from */
    target,
    /* a string of html to dump into the tooltip */
    html
  }) {
    Object.assign(this, {
      target,
      html,
      tooltipOpen: false
    });

    this.wrapper = document.createElement("div");
    this.wrapper.style.display = "none";
    this.wrapper.style.zIndex = 999;
    document.body.appendChild(this.wrapper);
    this.listenForMouseEnter();
  }

  onMouseEnter(event) {
    if (this.tooltipOpen) return;
    this.tooltipOpen = true;
    this.wrapper.innerHTML = this.html;
    this.popper = createPopper(this.target, this.wrapper, {
      placement: "top",
      modifiers: [{ name: "offset", options: { offset: [0, 10] } }]
    });
    this.wrapper.style.display = "block";
    this.target.removeEventListener("mouseenter", this.onMouseEnter);
    this.listenForMouseLeave();
  }

  onMouseLeave(event) {
    if (!this.tooltipOpen) return;
    this.popper.destroy();
    this.wrapper.style.display = "none";
    this.target.removeEventListener("mouseleave", this.onMouseLeave);
    this.wrapper.removeEventListener("mouseleave", this.onMouseLeave);
    this.listenForMouseEnter();
    this.tooltipOpen = false;
  }

  listenForMouseEnter() {
    this.target.addEventListener("mouseenter", event =>
      this.onMouseEnter(event)
    );
  }

  listenForMouseLeave() {
    this.target.addEventListener("mouseleave", event =>
      this.onMouseLeave(event)
    );
  }
}
