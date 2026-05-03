# Product

## Register

product

## Users

Public users — anyone who needs to shorten a URL and share it. No login required. Primary context: someone pastes a long URL, gets a short link, copies it, and shares it immediately. Secondary context: visiting the stats page to check click activity on a previously created link.

## Product Purpose

A lightweight, public URL shortener microservice. Users paste a target URL, receive a short link, and are redirected to the link's stats page. Stats track click count, originating geolocation, and timestamp per visit. The product exists to demonstrate clean microservice architecture and solid Rails engineering for a CoinGecko job placement submission.

## Brand Personality

Precise, professional, trustworthy. The interface should feel like a well-built tool — nothing flashy, nothing unnecessary. Users should feel confident that their link was created correctly and will work reliably.

## Anti-references

None specified. Avoid generic SaaS-blue clichés and crypto-neon aesthetics by default — neither fits the tone.

## Design Principles

1. **One job per screen.** The create page does one thing. The stats page does one thing. Don't bleed them together.
2. **Confidence through clarity.** Every state — loading, success, error — should be immediately legible. No ambiguity about what just happened.
3. **Earned simplicity.** Minimal not because it's easy, but because every element that isn't there is one fewer thing that can confuse.
4. **Data speaks for itself.** Stats are facts. Present them plainly — no decorative charts, no hero metrics, just readable information.

## Accessibility & Inclusion

WCAG AA. Standard contrast, keyboard navigable forms, clear focus states.
