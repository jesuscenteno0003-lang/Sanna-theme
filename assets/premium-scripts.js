/* ============================================
   SERENNE PREMIUM - Interactive Scripts
   ============================================ */

document.addEventListener('DOMContentLoaded', () => {
  // Initialize all components
  initHeader();
  initHero();
  initScrollReveal();
  initFAQ();
  initProductPage();
  initStickyATC();
  initLazyLoad();
  initSmoothScroll();
});

/* ---------- HEADER FUNCTIONALITY ---------- */
function initHeader() {
  const header = document.querySelector('.site-header');
  if (!header) return;

  let lastScroll = 0;
  const scrollThreshold = 100;

  window.addEventListener('scroll', debounce(() => {
    const currentScroll = window.pageYOffset;
    
    // Add scrolled class for shadow
    if (currentScroll > 50) {
      header.classList.add('scrolled');
    } else {
      header.classList.remove('scrolled');
    }

    // Hide/show on scroll direction
    if (currentScroll > scrollThreshold) {
      if (currentScroll > lastScroll && currentScroll > 300) {
        header.style.transform = 'translateY(-100%)';
      } else {
        header.style.transform = 'translateY(0)';
      }
    }
    
    lastScroll = currentScroll;
  }, 10));

  // Mobile menu toggle
  const mobileToggle = document.querySelector('.mobile-menu-toggle');
  const mobileMenu = document.querySelector('.mobile-menu');
  
  if (mobileToggle && mobileMenu) {
    mobileToggle.addEventListener('click', () => {
      mobileToggle.classList.toggle('active');
      mobileMenu.classList.toggle('open');
      document.body.style.overflow = mobileMenu.classList.contains('open') ? 'hidden' : '';
    });

    // Close on link click
    mobileMenu.querySelectorAll('a').forEach(link => {
      link.addEventListener('click', () => {
        mobileToggle.classList.remove('active');
        mobileMenu.classList.remove('open');
        document.body.style.overflow = '';
      });
    });
  }
}

/* ---------- HERO SECTION ---------- */
function initHero() {
  const hero = document.querySelector('.hero');
  if (!hero) return;

  // Parallax effect on scroll
  const heroImage = hero.querySelector('.hero-image') || hero.querySelector('.hero-bg img');
  const heroContent = hero.querySelector('.hero-content');

  window.addEventListener('scroll', debounce(() => {
    const scrolled = window.pageYOffset;
    const heroRect = hero.getBoundingClientRect();
    
    if (heroRect.bottom > 0) {
      const parallaxSpeed = 0.3;
      if (heroImage) heroImage.style.transform = `translateY(${scrolled * parallaxSpeed}px)`;
      
      // Fade out content on scroll
      const opacity = 1 - (scrolled / (heroRect.height * 0.8));
      if (heroContent) heroContent.style.opacity = Math.max(0, opacity);
    }
  }, 10));

  // Typewriter effect for hero title
  const heroTitle = hero.querySelector('.hero-title');
  if (heroTitle) {
    heroTitle.classList.add('animate-fade-in-up');
  }
}

/* ---------- SCROLL REVEAL ANIMATIONS ---------- */
function initScrollReveal() {
  const reveals = document.querySelectorAll('.reveal');
  
  const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        revealObserver.unobserve(entry.target);
      }
    });
  }, {
    threshold: 0.15,
    rootMargin: '0px 0px -50px 0px'
  });

  reveals.forEach(el => revealObserver.observe(el));

  // Animate elements with stagger
  const staggerGroups = document.querySelectorAll('.stagger-group');
  
  const staggerObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const children = entry.target.children;
        Array.from(children).forEach((child, index) => {
          child.style.animationDelay = `${index * 0.1}s`;
          child.classList.add('animate-fade-in-up');
        });
        staggerObserver.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1 });

  staggerGroups.forEach(el => staggerObserver.observe(el));
}

/* ---------- FAQ ACCORDION (uses native <details>/<summary>) ---------- */
function initFAQ() {
  const faqItems = document.querySelectorAll('.faq-item');
  
  faqItems.forEach(item => {
    const summary = item.querySelector('.faq-question');
    
    item.addEventListener('toggle', () => {
      const isOpen = item.open;
      summary.setAttribute('aria-expanded', isOpen);
      
      // Close other items when one opens
      if (isOpen) {
        faqItems.forEach(otherItem => {
          if (otherItem !== item && otherItem.open) {
            otherItem.open = false;
            otherItem.querySelector('.faq-question').setAttribute('aria-expanded', 'false');
          }
        });
      }
    });
  });
}

/* ---------- PRODUCT PAGE ---------- */
function initProductPage() {
  // Thumbnail gallery
  const thumbnails = document.querySelectorAll('.product-thumbnail');
  const mainImage = document.querySelector('.product-main-image img');
  
  thumbnails.forEach(thumb => {
    thumb.addEventListener('click', () => {
      // Update active state
      thumbnails.forEach(t => t.classList.remove('active'));
      thumb.classList.add('active');
      
      // Update main image with fade effect
      if (mainImage) {
        mainImage.style.opacity = '0';
        setTimeout(() => {
          mainImage.src = thumb.dataset.image;
          mainImage.style.opacity = '1';
        }, 200);
      }
    });
  });

  // Variant selector
  const variantOptions = document.querySelectorAll('.option-value');
  variantOptions.forEach(option => {
    option.addEventListener('click', () => {
      const group = option.closest('.option-values');
      group.querySelectorAll('.option-value').forEach(o => o.classList.remove('active'));
      option.classList.add('active');
      
      // Update price if variant has different price
      const price = option.dataset.price;
      if (price) {
        const priceEl = document.querySelector('.product-page-price');
        if (priceEl) priceEl.textContent = price;
      }
    });
  });

  // Quantity selector
  const quantityBtns = document.querySelectorAll('.quantity-btn');
  quantityBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      const input = btn.parentElement.querySelector('.quantity-input');
      let value = parseInt(input.value) || 1;
      
      if (btn.classList.contains('minus')) {
        value = Math.max(1, value - 1);
      } else {
        value = Math.min(10, value + 1);
      }
      
      input.value = value;
      
      // Update sticky ATC quantity
      const stickyInput = document.querySelector('.sticky-atc-qty input');
      if (stickyInput) stickyInput.value = value;
    });
  });

  // Product tabs
  const tabHeaders = document.querySelectorAll('.tab-header');
  const tabContents = document.querySelectorAll('.tab-content');
  
  tabHeaders.forEach(header => {
    header.addEventListener('click', () => {
      const target = header.dataset.tab;
      
      tabHeaders.forEach(h => h.classList.remove('active'));
      tabContents.forEach(c => c.classList.remove('active'));
      
      header.classList.add('active');
      document.querySelector(`[data-tab-content="${target}"]`)?.classList.add('active');
    });
  });

  // Image zoom on hover
  const mainImageContainer = document.querySelector('.product-main-image');
  if (mainImageContainer) {
    mainImageContainer.addEventListener('mousemove', (e) => {
      const rect = mainImageContainer.getBoundingClientRect();
      const x = (e.clientX - rect.left) / rect.width;
      const y = (e.clientY - rect.top) / rect.height;
      
      const img = mainImageContainer.querySelector('img');
      if (img) {
        img.style.transformOrigin = `${x * 100}% ${y * 100}%`;
        img.style.transform = 'scale(1.5)';
      }
    });
    
    mainImageContainer.addEventListener('mouseleave', () => {
      const img = mainImageContainer.querySelector('img');
      if (img) {
        img.style.transform = 'scale(1)';
      }
    });
  }
}

/* ---------- STICKY ADD TO CART ---------- */
function initStickyATC() {
  const stickyATC = document.querySelector('.sticky-atc');
  const addToCartBtn = document.querySelector('.product-add-to-cart .btn-primary');
  
  if (!stickyATC || !addToCartBtn) return;

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) {
        stickyATC.classList.add('visible');
      } else {
        stickyATC.classList.remove('visible');
      }
    });
  }, { threshold: 0 });

  observer.observe(addToCartBtn);

  // Sync quantity
  const stickyQtyInput = stickyATC.querySelector('.sticky-atc-qty input');
  const mainQtyInput = document.querySelector('.quantity-input');
  
  if (stickyQtyInput && mainQtyInput) {
    stickyQtyInput.addEventListener('change', () => {
      mainQtyInput.value = stickyQtyInput.value;
    });
  }
}

/* ---------- LAZY LOADING ---------- */
function initLazyLoad() {
  const lazyImages = document.querySelectorAll('img[data-src]');
  
  const imageObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const img = entry.target;
        img.src = img.dataset.src;
        img.classList.add('lazyloaded');
        imageObserver.unobserve(img);
      }
    });
  }, {
    rootMargin: '100px'
  });

  lazyImages.forEach(img => imageObserver.observe(img));
}

/* ---------- SMOOTH SCROLL ---------- */
function initSmoothScroll() {
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
      e.preventDefault();
      const target = document.querySelector(this.getAttribute('href'));
      if (target) {
        const headerHeight = document.querySelector('.site-header')?.offsetHeight || 0;
        const targetPosition = target.getBoundingClientRect().top + window.pageYOffset - headerHeight - 20;
        
        window.scrollTo({
          top: targetPosition,
          behavior: 'smooth'
        });
      }
    });
  });
}

/* ---------- CART FUNCTIONALITY ---------- */
function updateCartCount(count) {
  const cartCountEl = document.querySelector('.cart-count');
  if (cartCountEl) {
    cartCountEl.textContent = count;
    cartCountEl.style.animation = 'none';
    setTimeout(() => cartCountEl.style.animation = '', 10);
  }
}

function showAddToCartNotification(productName) {
  const notification = document.createElement('div');
  notification.className = 'add-to-cart-notification';
  
  const content = document.createElement('div');
  content.className = 'notification-content';
  
  const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
  svg.setAttribute('viewBox', '0 0 24 24');
  svg.setAttribute('fill', 'none');
  svg.setAttribute('stroke', 'currentColor');
  svg.setAttribute('stroke-width', '2');
  const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
  path.setAttribute('d', 'M20 6L9 17l-5-5');
  svg.appendChild(path);
  
  const span = document.createElement('span');
  span.textContent = productName + ' añadido al carrito';
  
  content.appendChild(svg);
  content.appendChild(span);
  notification.appendChild(content);
  
  document.body.appendChild(notification);
  
  setTimeout(() => {
    notification.classList.add('show');
  }, 10);
  
  setTimeout(() => {
    notification.classList.remove('show');
    setTimeout(() => notification.remove(), 300);
  }, 3000);
}

/* ---------- UTILITY: Debounce (uses global debounce from global.js) ---------- */

/* ---------- PERFORMANCE: Request Animation Frame ---------- */
function raf(callback) {
  if (window.requestAnimationFrame) {
    return window.requestAnimationFrame(callback);
  }
  return setTimeout(callback, 16);
}

/* ---------- EXPORT FOR SHOPIFY ---------- */
if (typeof Shopify !== 'undefined') {
  Shopify.addToCart = function(variantId, quantity = 1) {
    return fetch('/cart/add.js', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        id: variantId,
        quantity: quantity
      })
    })
    .then(response => response.json())
    .then(data => {
      updateCartCount(data.item_count);
      showAddToCartNotification(data.title);
      return data;
    });
  };
  
  Shopify.updateCart = function(variantId, quantity) {
    return fetch('/cart/update.js', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        updates: {
          [variantId]: quantity
        }
      })
    })
    .then(response => response.json())
    .then(data => {
      updateCartCount(data.item_count);
      return data;
    });
  };
}

/* ---------- NOTIFICATION STYLES (moved to premium-custom.css) ---------- */
