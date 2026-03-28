/* Zenza Pomodori — Minimal Interactions */
/* Note: the .js class is added via inline script in <head> to prevent FOUC */

(function () {
  'use strict';

  // Scroll reveal with IntersectionObserver
  function initScrollReveal() {
    var prefersReducedMotion = window.matchMedia(
      '(prefers-reduced-motion: reduce)'
    ).matches;

    if (prefersReducedMotion) {
      // Make everything visible immediately
      document.querySelectorAll('.reveal').forEach(function (el) {
        el.classList.add('visible');
      });
      return;
    }

    var observer = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            entry.target.classList.add('visible');
            observer.unobserve(entry.target);
          }
        });
      },
      {
        threshold: 0.1,
        rootMargin: '0px 0px -40px 0px',
      }
    );

    document.querySelectorAll('.reveal').forEach(function (el) {
      observer.observe(el);
    });
  }

  // Hero icon 3D tilt on hover
  function initIconTilt() {
    var icon = document.querySelector('.hero-icon');
    if (!icon) return;

    var prefersReducedMotion = window.matchMedia(
      '(prefers-reduced-motion: reduce)'
    ).matches;
    if (prefersReducedMotion) return;

    icon.addEventListener('mousemove', function (e) {
      var rect = icon.getBoundingClientRect();
      var x = (e.clientX - rect.left) / rect.width - 0.5;
      var y = (e.clientY - rect.top) / rect.height - 0.5;

      var svg = icon.querySelector('svg');
      if (svg) {
        svg.style.transform =
          'rotateY(' + x * 20 + 'deg) rotateX(' + -y * 20 + 'deg) scale(1.05)';
      }
    });

    icon.addEventListener('mouseleave', function () {
      var svg = icon.querySelector('svg');
      if (svg) {
        svg.style.transform = 'rotateY(0deg) rotateX(0deg) scale(1)';
      }
    });
  }

  // Smooth scroll for anchor links
  function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(function (link) {
      link.addEventListener('click', function (e) {
        var href = this.getAttribute('href');
        if (href === '#') return;

        var target = document.querySelector(href);
        if (target) {
          e.preventDefault();
          target.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
      });
    });
  }

  // Initialize
  document.addEventListener('DOMContentLoaded', function () {
    initScrollReveal();
    initIconTilt();
    initSmoothScroll();
  });
})();
