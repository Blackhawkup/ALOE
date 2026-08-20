/**
 * Backward-compatible ALOE export surface.
 *
 * The implementation lives in the product-neutral @blockrun/router-core
 * package. Keeping this adapter preserves aloe/router for
 * existing SDK consumers without coupling Router Core back to this product.
 */
export * from "@blockrun/router-core";
