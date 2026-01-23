import { jsx, jsxs, Fragment } from "react/jsx-runtime";
import { createReadableStreamFromReadable } from "@react-router/node";
import * as Sentry from "@sentry/node";
import { createInstance } from "i18next";
import { isbot } from "isbot";
import { PassThrough } from "node:stream";
import { renderToPipeableStream } from "react-dom/server";
import { initReactI18next, I18nextProvider, useTranslation } from "react-i18next";
import { createCookie, ServerRouter, useMatches, useActionData, useLoaderData, useParams, useRouteError, createCookieSessionStorage, Link, useRouteLoaderData, useNavigation, useNavigate, useLocation, Outlet, Meta, Links, ScrollRestoration, Scripts, isRouteErrorResponse, Form, data, useFetcher, useSearchParams, NavLink } from "react-router";
import "i18next-resources-to-backend";
import { RemixI18Next } from "remix-i18next/server";
import { createElement, useEffect, useState } from "react";
import "@sentry/react-router";
import NProgress from "nprogress";
import { useChangeLanguage } from "remix-i18next/react";
import { createThemeSessionResolver, ThemeProvider, useTheme, PreventFlashOnWrongTheme, createThemeAction, Theme } from "remix-themes";
import { Toaster, toast } from "sonner";
import * as DialogPrimitive from "@radix-ui/react-dialog";
import { clsx } from "clsx";
import { XIcon, Smartphone, Copy, Download, LoaderCircleIcon, CheckCircle2Icon, MonitorIcon, SunIcon, MoonIcon, MenuIcon, CogIcon, HomeIcon, LogOutIcon, LayoutDashboard, Users, Group, Target, Settings, Crown, BookOpen, User, ArrowRight, Plus, ArrowLeft } from "lucide-react";
import { twMerge } from "tailwind-merge";
import { Slot } from "@radix-ui/react-slot";
import { cva } from "class-variance-authority";
import { z } from "zod";
import * as DropdownMenuPrimitive from "@radix-ui/react-dropdown-menu";
import * as AvatarPrimitive from "@radix-ui/react-avatar";
import * as SeparatorPrimitive from "@radix-ui/react-separator";
import { getAuth, onAuthStateChanged, signOut as signOut$1, signInWithEmailAndPassword } from "firebase/auth";
import { getApps, initializeApp, getApp } from "firebase/app";
import { getFirestore, doc, getDoc, collection, getCountFromServer, getDocs, query, where } from "firebase/firestore";
import * as LabelPrimitive from "@radix-ui/react-label";
import { ResponsiveContainer, LineChart, XAxis, YAxis, CartesianGrid, Tooltip, Line, BarChart, Bar } from "recharts";
const supportedLngs = ["en", "es", "ko"];
const i18n = {
  // List of languages the application supports
  supportedLngs,
  // Fallback language when user's preferred language is not supported
  // English is used as the default fallback
  fallbackLng: "en",
  // The default namespace for translations
  // All general translations are stored in the 'common' namespace
  defaultNS: "common"
};
const en = {
  home: {
    title: "Supaplate",
    subtitle: "It's time to build!"
  },
  navigation: {
    en: "English",
    kr: "Korean",
    es: "Spanish"
  },
  matchcard: {
    tbd: "TBD"
  }
};
const es = {
  home: {
    title: "Supaplate",
    subtitle: "Es hora de construir!"
  },
  navigation: {
    en: "Inglés",
    kr: "Coreano",
    es: "Español"
  },
  matchcard: {
    tbd: "TBD"
  }
};
const ko = {
  home: {
    title: "CCLab Admin",
    subtitle: "공동체 성경 읽기 관리"
  },
  navigation: {
    kr: "한국어",
    es: "스페인어",
    en: "영어"
  },
  matchcard: {
    tbd: "TBD"
  }
};
const localeCookie = createCookie("locale", {
  path: "/",
  sameSite: "lax"
});
const i18next = new RemixI18Next({
  // Language detection configuration
  detection: {
    // Use the localeCookie for persistent language preference
    cookie: localeCookie,
    // Languages supported by the application
    supportedLanguages: i18n.supportedLngs,
    // Fallback language when the requested language is not available
    fallbackLanguage: i18n.fallbackLng
  },
  // i18next configuration
  i18next: {
    // Spread the base i18n configuration
    ...i18n,
    // In-memory translation resources for each supported language
    resources: {
      // English translations
      en: {
        common: en
      },
      // Spanish translations
      es: {
        common: es
      },
      // Korean translations
      ko: {
        common: ko
      }
    }
  }
});
const streamTimeout = 5e3;
async function handleRequest(request, responseStatusCode, responseHeaders, routerContext, loadContext) {
  return new Promise(async (resolve, reject) => {
    const i18nextInstance = createInstance();
    const lng = await i18next.getLocale(request);
    const ns = i18next.getRouteNamespaces(routerContext);
    await i18nextInstance.use(initReactI18next).init({
      ...i18n,
      lng,
      ns,
      resources: {
        en: {
          common: en
        },
        es: {
          common: es
        },
        ko: {
          common: ko
        }
      }
    });
    let shellRendered = false;
    let userAgent = request.headers.get("user-agent");
    let readyOption = userAgent && isbot(userAgent) || routerContext.isSpaMode ? "onAllReady" : "onShellReady";
    const { pipe, abort } = renderToPipeableStream(
      /* @__PURE__ */ jsx(I18nextProvider, { i18n: i18nextInstance, children: /* @__PURE__ */ jsx(ServerRouter, { context: routerContext, url: request.url }) }),
      {
        [readyOption]() {
          shellRendered = true;
          const body = new PassThrough();
          const stream = createReadableStreamFromReadable(body);
          responseHeaders.set("Content-Type", "text/html");
          responseHeaders.set(
            "Strict-Transport-Security",
            "max-age=31536000; includeSubDomains; preload"
          );
          if (process.env.NODE_ENV === "production") ;
          responseHeaders.set("X-Content-Type-Options", "nosniff");
          responseHeaders.set(
            "Referrer-Policy",
            "strict-origin-when-cross-origin"
          );
          responseHeaders.set("Cross-Origin-Opener-Policy", "same-origin");
          responseHeaders.set("Cross-Origin-Embedder-Policy", "unsafe-none");
          responseHeaders.set("X-Frame-Options", "DENY");
          responseHeaders.set("X-XSS-Protection", "1; mode=block");
          resolve(
            new Response(stream, {
              headers: responseHeaders,
              status: responseStatusCode
            })
          );
          pipe(body);
        },
        onShellError(error2) {
          reject(error2);
        },
        onError(error2) {
          responseStatusCode = 500;
          if (shellRendered) {
            console.error(error2);
          }
        }
      }
    );
    setTimeout(abort, streamTimeout + 1e3);
  });
}
const handleError = (error2, { request }) => {
  if (!request.signal.aborted && process.env.SENTRY_DSN && process.env.NODE_ENV === "production") {
    Sentry.captureException(error2);
    console.error(error2);
  }
};
const entryServer = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: handleRequest,
  handleError,
  streamTimeout
}, Symbol.toStringTag, { value: "Module" }));
function withComponentProps(Component) {
  return function Wrapped() {
    const props = {
      params: useParams(),
      loaderData: useLoaderData(),
      actionData: useActionData(),
      matches: useMatches()
    };
    return createElement(Component, props);
  };
}
function withErrorBoundaryProps(ErrorBoundary3) {
  return function Wrapped() {
    const props = {
      params: useParams(),
      loaderData: useLoaderData(),
      actionData: useActionData(),
      error: useRouteError()
    };
    return createElement(ErrorBoundary3, props);
  };
}
const nProgressStyles = "/assets/nprogress-BgDCIyLK.css";
function cn(...inputs) {
  return twMerge(clsx(inputs));
}
function Dialog({
  ...props
}) {
  return /* @__PURE__ */ jsx(DialogPrimitive.Root, { "data-slot": "dialog", ...props });
}
function Sheet({ ...props }) {
  return /* @__PURE__ */ jsx(DialogPrimitive.Root, { "data-slot": "sheet", ...props });
}
function SheetTrigger({
  ...props
}) {
  return /* @__PURE__ */ jsx(DialogPrimitive.Trigger, { "data-slot": "sheet-trigger", ...props });
}
function SheetClose({
  ...props
}) {
  return /* @__PURE__ */ jsx(DialogPrimitive.Close, { "data-slot": "sheet-close", ...props });
}
function SheetPortal({
  ...props
}) {
  return /* @__PURE__ */ jsx(DialogPrimitive.Portal, { "data-slot": "sheet-portal", ...props });
}
function SheetOverlay({
  className,
  ...props
}) {
  return /* @__PURE__ */ jsx(
    DialogPrimitive.Overlay,
    {
      "data-slot": "sheet-overlay",
      className: cn(
        "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 fixed inset-0 z-50 bg-black/50",
        className
      ),
      ...props
    }
  );
}
function SheetContent({
  className,
  children,
  side = "right",
  ...props
}) {
  return /* @__PURE__ */ jsxs(SheetPortal, { children: [
    /* @__PURE__ */ jsx(SheetOverlay, {}),
    /* @__PURE__ */ jsxs(
      DialogPrimitive.Content,
      {
        "data-slot": "sheet-content",
        className: cn(
          "bg-background data-[state=open]:animate-in data-[state=closed]:animate-out fixed z-50 flex flex-col gap-4 shadow-lg transition ease-in-out data-[state=closed]:duration-300 data-[state=open]:duration-500",
          side === "right" && "data-[state=closed]:slide-out-to-right data-[state=open]:slide-in-from-right inset-y-0 right-0 h-full w-3/4 border-l sm:max-w-sm",
          side === "left" && "data-[state=closed]:slide-out-to-left data-[state=open]:slide-in-from-left inset-y-0 left-0 h-full w-3/4 border-r sm:max-w-sm",
          side === "top" && "data-[state=closed]:slide-out-to-top data-[state=open]:slide-in-from-top inset-x-0 top-0 h-auto border-b",
          side === "bottom" && "data-[state=closed]:slide-out-to-bottom data-[state=open]:slide-in-from-bottom inset-x-0 bottom-0 h-auto border-t",
          className
        ),
        ...props,
        children: [
          children,
          /* @__PURE__ */ jsxs(DialogPrimitive.Close, { className: "ring-offset-background focus:ring-ring data-[state=open]:bg-secondary absolute top-4 right-4 rounded-xs opacity-70 transition-opacity hover:opacity-100 focus:ring-2 focus:ring-offset-2 focus:outline-hidden disabled:pointer-events-none", children: [
            /* @__PURE__ */ jsx(XIcon, { className: "size-4" }),
            /* @__PURE__ */ jsx("span", { className: "sr-only", children: "Close" })
          ] })
        ]
      }
    )
  ] });
}
function SheetHeader({ className, ...props }) {
  return /* @__PURE__ */ jsx(
    "div",
    {
      "data-slot": "sheet-header",
      className: cn("flex flex-col gap-1.5 p-4", className),
      ...props
    }
  );
}
function SheetFooter({ className, ...props }) {
  return /* @__PURE__ */ jsx(
    "div",
    {
      "data-slot": "sheet-footer",
      className: cn("mt-auto flex flex-col gap-2 p-4", className),
      ...props
    }
  );
}
const sessionStorage = createCookieSessionStorage({
  cookie: {
    name: "theme",
    path: "/",
    httpOnly: false,
    sameSite: "lax"
  }
});
const themeSessionResolver = createThemeSessionResolver(sessionStorage);
const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-all disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4 shrink-0 [&_svg]:shrink-0 cursor-pointer outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground shadow-xs hover:bg-primary/90",
        destructive: "bg-destructive text-white shadow-xs hover:bg-destructive/90 focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40 dark:bg-destructive/60",
        outline: "border bg-background shadow-xs hover:bg-accent hover:text-accent-foreground dark:bg-input/30 dark:border-input dark:hover:bg-input/50",
        secondary: "bg-secondary text-secondary-foreground shadow-xs hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground dark:hover:bg-accent/50",
        link: "text-primary underline-offset-4 hover:underline"
      },
      size: {
        default: "h-9 px-4 py-2 has-[>svg]:px-3",
        sm: "h-8 rounded-md gap-1.5 px-3 has-[>svg]:px-2.5",
        lg: "h-10 rounded-md px-6 has-[>svg]:px-4",
        icon: "size-9"
      }
    },
    defaultVariants: {
      variant: "default",
      size: "default"
    }
  }
);
function Button({
  className,
  variant,
  size,
  asChild = false,
  ...props
}) {
  const Comp = asChild ? Slot : "button";
  return /* @__PURE__ */ jsx(
    Comp,
    {
      "data-slot": "button",
      className: cn(buttonVariants({ variant, size, className })),
      ...props
    }
  );
}
function NotFound() {
  return /* @__PURE__ */ jsxs("div", { className: "flex h-screen flex-col items-center justify-center gap-2.5", children: [
    /* @__PURE__ */ jsx("h1", { className: "text-5xl font-semibold", children: "Page not found" }),
    /* @__PURE__ */ jsx("h2", { className: "text-2xl", children: "The page you are looking for does not exist." }),
    /* @__PURE__ */ jsx(Button, { variant: "outline", asChild: true, children: /* @__PURE__ */ jsx(Link, { to: "/", children: "Go home →" }) })
  ] });
}
const links = () => [{
  rel: "icon",
  href: "/favicon.ico"
}, {
  rel: "preconnect",
  href: "https://fonts.googleapis.com"
}, {
  rel: "preconnect",
  href: "https://fonts.gstatic.com",
  crossOrigin: "anonymous"
}, {
  rel: "stylesheet",
  href: "https://fonts.googleapis.com/css2?family=Geist:wght@100..900&display=swap"
}, {
  rel: "stylesheet",
  href: nProgressStyles
}];
async function loader$9({
  request
}) {
  const [{
    getTheme
  }, locale] = await Promise.all([themeSessionResolver(request), i18next.getLocale(request)]);
  return {
    theme: getTheme(),
    locale
  };
}
const handle = {
  i18n: "common"
};
function Layout({
  children
}) {
  const data2 = useRouteLoaderData("root");
  return /* @__PURE__ */ jsx(ThemeProvider, {
    specifiedTheme: (data2 == null ? void 0 : data2.theme) ?? "dark",
    themeAction: "/api/settings/theme",
    children: /* @__PURE__ */ jsx(InnerLayout, {
      children
    })
  });
}
function InnerLayout({
  children
}) {
  const [theme] = useTheme();
  const data2 = useRouteLoaderData("root");
  const {
    i18n: i18n2
  } = useTranslation();
  const {
    pathname
  } = useLocation();
  useChangeLanguage((data2 == null ? void 0 : data2.locale) ?? "en");
  const isPreRendered = pathname.includes("/legal") || pathname.includes("/blog");
  return /* @__PURE__ */ jsxs("html", {
    lang: (data2 == null ? void 0 : data2.locale) ?? "en",
    className: cn(theme ?? "", "h-full"),
    dir: i18n2.dir(),
    children: [/* @__PURE__ */ jsxs("head", {
      children: [/* @__PURE__ */ jsx("meta", {
        charSet: "utf-8"
      }), /* @__PURE__ */ jsx("meta", {
        name: "viewport",
        content: "width=device-width, initial-scale=1"
      }), /* @__PURE__ */ jsx(Meta, {}), /* @__PURE__ */ jsx(Links, {}), isPreRendered ? /* @__PURE__ */ jsx("script", {
        src: "/scripts/prerendered-theme.js"
      }) : /* @__PURE__ */ jsx(PreventFlashOnWrongTheme, {
        ssrTheme: Boolean(data2 == null ? void 0 : data2.theme)
      })]
    }), /* @__PURE__ */ jsxs("body", {
      className: "h-full",
      children: [children, /* @__PURE__ */ jsx(Toaster, {
        richColors: true,
        position: "bottom-right"
      }), /* @__PURE__ */ jsx(ScrollRestoration, {}), /* @__PURE__ */ jsx(Scripts, {}), void 0, void 0]
    })]
  });
}
const root = withComponentProps(function App() {
  const navigation = useNavigation();
  useEffect(() => {
    NProgress.configure({
      showSpinner: true
    });
  }, []);
  useEffect(() => {
    if (navigation.state === "loading") {
      NProgress.start();
    } else if (navigation.state === "idle") {
      NProgress.done();
    }
  }, [navigation.state]);
  useNavigate();
  useLocation();
  return /* @__PURE__ */ jsx(Sheet, {
    children: /* @__PURE__ */ jsx(Dialog, {
      children: /* @__PURE__ */ jsx(Outlet, {})
    })
  });
});
const ErrorBoundary = withErrorBoundaryProps(function ErrorBoundary2({
  error: error2
}) {
  let message = "Oops!";
  let details = "An unexpected error occurred.";
  let stack;
  if (isRouteErrorResponse(error2)) {
    if (error2.status === 404) {
      return /* @__PURE__ */ jsx(NotFound, {});
    }
    message = "Error";
    details = error2.statusText || details;
  }
  return /* @__PURE__ */ jsxs("main", {
    className: "container mx-auto p-4 pt-16",
    children: [/* @__PURE__ */ jsx("h1", {
      children: message
    }), /* @__PURE__ */ jsx("p", {
      children: details
    }), stack]
  });
});
const route0 = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  ErrorBoundary,
  Layout,
  default: root,
  handle,
  links,
  loader: loader$9
}, Symbol.toStringTag, { value: "Module" }));
async function loader$8() {
  return new Response(`User-agent: *
Disallow: /dashboard
Disallow: /account
Disallow: /settings
Disallow: /payments
Disallow: /api
Allow: /

Sitemap: ${process.env.SITE_URL}/sitemap.xml`, {
    headers: {
      "Content-Type": "text/plain"
    }
  });
}
const route1 = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  loader: loader$8
}, Symbol.toStringTag, { value: "Module" }));
async function loader$7() {
  const DOMAIN = process.env.SITE_URL || "https://example.com";
  const customUrls = ["/"];
  const sitemapUrls = customUrls.map((url) => {
    return `<url>
      <loc>${DOMAIN}${url}</loc>
      <lastmod>${(/* @__PURE__ */ new Date()).toISOString()}</lastmod>
    </url>`;
  });
  return new Response(`<?xml version="1.0" encoding="UTF-8"?>
    <urlset
      xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"
    >
      ${sitemapUrls.join("\n")}
    </urlset>
    `, {
    headers: {
      "Content-Type": "application/xml"
    }
  });
}
const route2 = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  loader: loader$7
}, Symbol.toStringTag, { value: "Module" }));
const APP_SCHEME = "omp-camera://";
const ANDROID_PACKAGE_NAME = "com.ohmyplay.camera";
const APP_STORE_ID = "123456789";
const APP_STORE_URL = `https://apps.apple.com/app/id${APP_STORE_ID}`;
const PLAY_STORE_URL = `https://play.google.com/store/apps/details?id=${ANDROID_PACKAGE_NAME}`;
const inviteRedirect = withComponentProps(function InviteRedirect() {
  const {
    code
  } = useParams();
  const [status, setStatus] = useState("detecting");
  const [isMobile, setIsMobile] = useState(false);
  useEffect(() => {
    if (typeof window === "undefined") return;
    const userAgent = navigator.userAgent || navigator.vendor || window.opera;
    const isAndroid = /android/i.test(userAgent);
    const isIOS = /iPad|iPhone|iPod/.test(userAgent) && !window.MSStream;
    setIsMobile(isAndroid || isIOS);
    const redirect = () => {
      setStatus("redirecting");
      const deepLink = `${APP_SCHEME}invite/${code}`;
      if (isAndroid) {
        const intentUrl = `intent://invite/${code}#Intent;scheme=${APP_SCHEME.replace("://", "")};package=${ANDROID_PACKAGE_NAME};end`;
        window.location.href = intentUrl;
      } else if (isIOS) {
        window.location.href = deepLink;
        setTimeout(() => {
          window.location.href = APP_STORE_URL;
        }, 1500);
      } else {
        setStatus("manual");
      }
    };
    const timer = setTimeout(() => {
      redirect();
    }, 1e3);
    return () => clearTimeout(timer);
  }, [code]);
  return /* @__PURE__ */ jsx("div", {
    className: "min-h-screen bg-slate-50 flex flex-col items-center justify-center p-4",
    children: /* @__PURE__ */ jsxs("div", {
      className: "max-w-md w-full bg-white rounded-2xl shadow-xl overflow-hidden animate-in fade-in zoom-in duration-500",
      children: [/* @__PURE__ */ jsxs("div", {
        className: "bg-slate-900 p-8 text-center text-white",
        children: [/* @__PURE__ */ jsx("div", {
          className: "mx-auto bg-slate-800 w-16 h-16 rounded-full flex items-center justify-center mb-4 ring-4 ring-slate-700",
          children: /* @__PURE__ */ jsx(Smartphone, {
            className: "w-8 h-8 text-blue-400"
          })
        }), /* @__PURE__ */ jsx("h1", {
          className: "text-2xl font-bold mb-2",
          children: "OMP Camera 초대"
        }), /* @__PURE__ */ jsx("p", {
          className: "text-slate-300",
          children: code ? "초대 코드가 확인되었습니다." : "초대 코드를 확인하는 중..."
        })]
      }), /* @__PURE__ */ jsxs("div", {
        className: "p-8 space-y-6",
        children: [code && /* @__PURE__ */ jsxs("div", {
          className: "bg-slate-50 p-4 rounded-lg border border-slate-200 flex items-center justify-between",
          children: [/* @__PURE__ */ jsxs("div", {
            className: "flex flex-col",
            children: [/* @__PURE__ */ jsx("span", {
              className: "text-xs text-slate-500 font-medium uppercase tracking-wider",
              children: "초대 코드"
            }), /* @__PURE__ */ jsx("span", {
              className: "text-xl font-mono font-bold text-slate-900",
              children: code
            })]
          }), /* @__PURE__ */ jsx("button", {
            onClick: () => {
              navigator.clipboard.writeText(code);
              alert("코드가 복사되었습니다!");
            },
            className: "p-2 hover:bg-white rounded-md transition-colors text-slate-400 hover:text-blue-600",
            title: "복사하기",
            children: /* @__PURE__ */ jsx(Copy, {
              size: 20
            })
          })]
        }), /* @__PURE__ */ jsxs("div", {
          className: "space-y-3",
          children: [/* @__PURE__ */ jsxs("a", {
            href: isMobile ? navigator.userAgent.match(/android/i) ? `intent://invite/${code}#Intent;scheme=${APP_SCHEME.replace("://", "")};package=${ANDROID_PACKAGE_NAME};end` : `${APP_SCHEME}invite/${code}` : "#",
            className: "w-full flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-700 text-white py-3 px-4 rounded-xl font-semibold transition-all hover:scale-[1.02] active:scale-[0.98] shadow-md shadow-blue-200",
            children: [/* @__PURE__ */ jsx(Smartphone, {
              size: 20
            }), "앱으로 열기"]
          }), /* @__PURE__ */ jsxs("div", {
            className: "relative",
            children: [/* @__PURE__ */ jsx("div", {
              className: "absolute inset-0 flex items-center",
              children: /* @__PURE__ */ jsx("span", {
                className: "w-full border-t border-slate-200"
              })
            }), /* @__PURE__ */ jsx("div", {
              className: "relative flex justify-center text-xs uppercase",
              children: /* @__PURE__ */ jsx("span", {
                className: "bg-white px-2 text-slate-500",
                children: "또는 앱이 없다면"
              })
            })]
          }), /* @__PURE__ */ jsxs("div", {
            className: "grid grid-cols-2 gap-3",
            children: [/* @__PURE__ */ jsxs("a", {
              href: PLAY_STORE_URL,
              target: "_blank",
              rel: "noreferrer",
              className: "flex flex-col items-center justify-center gap-1 bg-slate-100 hover:bg-slate-200 text-slate-700 py-3 px-2 rounded-xl text-sm font-medium transition-colors",
              children: [/* @__PURE__ */ jsx(Download, {
                size: 16
              }), "Google Play"]
            }), /* @__PURE__ */ jsxs("a", {
              href: APP_STORE_URL,
              target: "_blank",
              rel: "noreferrer",
              className: "flex flex-col items-center justify-center gap-1 bg-slate-100 hover:bg-slate-200 text-slate-700 py-3 px-2 rounded-xl text-sm font-medium transition-colors",
              children: [/* @__PURE__ */ jsx(Download, {
                size: 16
              }), "App Store"]
            })]
          })]
        }), /* @__PURE__ */ jsx("div", {
          className: "text-center",
          children: /* @__PURE__ */ jsx("p", {
            className: "text-xs text-slate-400",
            children: status === "redirecting" ? "앱을 실행하는 중입니다..." : "버튼을 눌러 직접 이동할 수 있습니다."
          })
        })]
      })]
    })
  });
});
const route3 = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: inviteRedirect
}, Symbol.toStringTag, { value: "Module" }));
const meta$9 = () => {
  return [{
    title: `Sentry Test | ${void 0}`
  }];
};
function action$2() {
  throw new Error("This is a test error, you should see it in Sentry");
}
const sentry = withComponentProps(function TriggerError() {
  return /* @__PURE__ */ jsxs("div", {
    className: "flex h-screen flex-col items-center justify-center gap-2 px-5 py-10 md:px-10 md:py-20",
    children: [/* @__PURE__ */ jsx("h1", {
      className: "text-2xl font-semibold",
      children: "Sentry Test"
    }), /* @__PURE__ */ jsx("p", {
      className: "text-muted-foreground text-center",
      children: "Test that the Sentry integration is working by triggering an error clicking the button below."
    }), /* @__PURE__ */ jsx(Form, {
      method: "post",
      className: "mt-5",
      children: /* @__PURE__ */ jsx(Button, {
        children: "Trigger Error"
      })
    })]
  });
});
const route4 = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  action: action$2,
  default: sentry,
  meta: meta$9
}, Symbol.toStringTag, { value: "Module" }));
const trackEvent = void 0;
const meta$8 = () => {
  return [{
    title: `Google Tag Test | ${void 0}`
  }];
};
async function clientAction() {
  trackEvent("test_event", {
    test: "test",
    time: (/* @__PURE__ */ new Date()).toISOString()
  });
  return {
    success: true
  };
}
const analytics = withComponentProps(function TriggerEvent({
  actionData
}) {
  const {
    state
  } = useNavigation();
  return /* @__PURE__ */ jsxs("div", {
    className: "flex h-screen flex-col items-center justify-center gap-2 px-5 py-10 md:px-10 md:py-20",
    children: [/* @__PURE__ */ jsx("h1", {
      className: "text-2xl font-semibold",
      children: "Google Tag Test"
    }), /* @__PURE__ */ jsx("p", {
      className: "text-muted-foreground text-center",
      children: "Test that the Google Tag integration is working by clicking the button below."
    }), /* @__PURE__ */ jsx(Form, {
      method: "post",
      className: "mt-5 flex w-xs justify-center",
      children: /* @__PURE__ */ jsx(Button, {
        disabled: state === "submitting",
        type: "submit",
        className: "w-1/2",
        children: state === "submitting" ? /* @__PURE__ */ jsx(Fragment, {
          children: /* @__PURE__ */ jsx(LoaderCircleIcon, {
            className: "size-4 animate-spin"
          })
        }) : "Trigger Event"
      })
    }), (actionData == null ? void 0 : actionData.success) && /* @__PURE__ */ jsxs("p", {
      className: "text-muted-foreground flex items-center gap-2",
      children: [/* @__PURE__ */ jsx(CheckCircle2Icon, {
        className: "size-4 text-green-600"
      }), " Event triggered successfully"]
    })]
  });
});
const route5 = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  clientAction,
  default: analytics,
  meta: meta$8
}, Symbol.toStringTag, { value: "Module" }));
const action$1 = createThemeAction(themeSessionResolver);
const route6 = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  action: action$1
}, Symbol.toStringTag, { value: "Module" }));
const localeSchema = z.enum(i18n.supportedLngs);
async function action({
  request
}) {
  const url = new URL(request.url);
  const locale = localeSchema.parse(url.searchParams.get("locale"));
  return data(null, {
    headers: {
      "Set-Cookie": await localeCookie.serialize(locale)
    }
  });
}
const route7 = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  action
}, Symbol.toStringTag, { value: "Module" }));
function Footer() {
  return /* @__PURE__ */ jsx("footer", { className: "text-muted-foreground mt-auto flex items-center justify-between border-t py-3 text-sm md:py-5", children: /* @__PURE__ */ jsxs("div", { className: "mx-auto flex h-full w-full max-w-screen-2xl flex-col items-center justify-between gap-2.5 md:order-none md:flex-row md:gap-0", children: [
    /* @__PURE__ */ jsx("div", { className: "order-2 md:order-none", children: /* @__PURE__ */ jsxs("p", { children: [
      "© ",
      (/* @__PURE__ */ new Date()).getFullYear(),
      " ",
      void 0,
      ". All rights reserved."
    ] }) }),
    /* @__PURE__ */ jsxs("div", { className: "order-1 flex gap-10 *:underline md:order-none", children: [
      /* @__PURE__ */ jsx(Link, { to: "/legal/privacy-policy", viewTransition: true, children: "Privacy Policy" }),
      /* @__PURE__ */ jsx(Link, { to: "/legal/terms-of-service", viewTransition: true, children: "Terms of Service" })
    ] })
  ] }) });
}
function DropdownMenu({
  ...props
}) {
  return /* @__PURE__ */ jsx(DropdownMenuPrimitive.Root, { "data-slot": "dropdown-menu", ...props });
}
function DropdownMenuTrigger({
  ...props
}) {
  return /* @__PURE__ */ jsx(
    DropdownMenuPrimitive.Trigger,
    {
      "data-slot": "dropdown-menu-trigger",
      ...props
    }
  );
}
function DropdownMenuContent({
  className,
  sideOffset = 4,
  ...props
}) {
  return /* @__PURE__ */ jsx(DropdownMenuPrimitive.Portal, { children: /* @__PURE__ */ jsx(
    DropdownMenuPrimitive.Content,
    {
      "data-slot": "dropdown-menu-content",
      sideOffset,
      className: cn(
        "bg-popover text-popover-foreground data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2 z-50 max-h-(--radix-dropdown-menu-content-available-height) min-w-[8rem] origin-(--radix-dropdown-menu-content-transform-origin) overflow-x-hidden overflow-y-auto rounded-md border p-1 shadow-md",
        className
      ),
      ...props
    }
  ) });
}
function DropdownMenuItem({
  className,
  inset,
  variant = "default",
  ...props
}) {
  return /* @__PURE__ */ jsx(
    DropdownMenuPrimitive.Item,
    {
      "data-slot": "dropdown-menu-item",
      "data-inset": inset,
      "data-variant": variant,
      className: cn(
        "focus:bg-accent focus:text-accent-foreground data-[variant=destructive]:text-destructive data-[variant=destructive]:focus:bg-destructive/10 dark:data-[variant=destructive]:focus:bg-destructive/20 data-[variant=destructive]:focus:text-destructive data-[variant=destructive]:*:[svg]:!text-destructive [&_svg:not([class*='text-'])]:text-muted-foreground relative flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-hidden select-none data-[disabled]:pointer-events-none data-[disabled]:opacity-50 data-[inset]:pl-8 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4",
        className
      ),
      ...props
    }
  );
}
function DropdownMenuLabel({
  className,
  inset,
  ...props
}) {
  return /* @__PURE__ */ jsx(
    DropdownMenuPrimitive.Label,
    {
      "data-slot": "dropdown-menu-label",
      "data-inset": inset,
      className: cn(
        "px-2 py-1.5 text-sm font-medium data-[inset]:pl-8",
        className
      ),
      ...props
    }
  );
}
function DropdownMenuSeparator({
  className,
  ...props
}) {
  return /* @__PURE__ */ jsx(
    DropdownMenuPrimitive.Separator,
    {
      "data-slot": "dropdown-menu-separator",
      className: cn("bg-border -mx-1 my-1 h-px", className),
      ...props
    }
  );
}
function LangSwitcher() {
  const { t, i18n: i18n2 } = useTranslation();
  const fetcher = useFetcher();
  const handleLocaleChange = async (locale) => {
    i18n2.changeLanguage(locale);
    await fetcher.submit(null, {
      method: "POST",
      action: "/api/settings/locale?locale=" + locale
    });
  };
  return /* @__PURE__ */ jsxs(DropdownMenu, { children: [
    /* @__PURE__ */ jsx(
      DropdownMenuTrigger,
      {
        asChild: true,
        className: "cursor-pointer",
        "data-testid": "lang-switcher",
        children: /* @__PURE__ */ jsx(Button, { variant: "ghost", size: "icon", className: "text-lg", children: i18n2.language === "en" ? "🇬🇧" : i18n2.language === "ko" ? "🇰🇷" : i18n2.language === "es" ? "🇪🇸" : null })
      }
    ),
    /* @__PURE__ */ jsxs(DropdownMenuContent, { align: "end", children: [
      /* @__PURE__ */ jsxs(DropdownMenuItem, { onClick: () => handleLocaleChange("es"), children: [
        "🇪🇸 ",
        t("navigation.es"),
        " "
      ] }),
      /* @__PURE__ */ jsxs(DropdownMenuItem, { onClick: () => handleLocaleChange("ko"), children: [
        "🇰🇷 ",
        t("navigation.kr"),
        " "
      ] }),
      /* @__PURE__ */ jsxs(DropdownMenuItem, { onClick: () => handleLocaleChange("en"), children: [
        "🇬🇧 ",
        t("navigation.en"),
        " "
      ] })
    ] })
  ] });
}
function ThemeSwitcher() {
  const [theme, setTheme, metadata] = useTheme();
  return /* @__PURE__ */ jsxs(DropdownMenu, { children: [
    /* @__PURE__ */ jsx(
      DropdownMenuTrigger,
      {
        asChild: true,
        className: "cursor-pointer",
        "data-testid": "theme-switcher",
        children: /* @__PURE__ */ jsx(Button, { variant: "ghost", size: "icon", children: metadata.definedBy === "SYSTEM" ? /* @__PURE__ */ jsx(MonitorIcon, { className: "size-4" }) : theme === Theme.LIGHT ? /* @__PURE__ */ jsx(SunIcon, { className: "size-4" }) : theme === Theme.DARK ? /* @__PURE__ */ jsx(MoonIcon, { className: "size-4" }) : null })
      }
    ),
    /* @__PURE__ */ jsxs(DropdownMenuContent, { align: "end", children: [
      /* @__PURE__ */ jsxs(DropdownMenuItem, { onClick: () => setTheme(Theme.LIGHT), children: [
        /* @__PURE__ */ jsx(SunIcon, { className: "size-4" }),
        "Light"
      ] }),
      /* @__PURE__ */ jsxs(DropdownMenuItem, { onClick: () => setTheme(Theme.DARK), children: [
        /* @__PURE__ */ jsx(MoonIcon, { className: "size-4" }),
        " Dark"
      ] }),
      /* @__PURE__ */ jsxs(DropdownMenuItem, { onClick: () => setTheme(null), children: [
        /* @__PURE__ */ jsx(MonitorIcon, { className: "size-4" }),
        " System"
      ] })
    ] })
  ] });
}
function Avatar({
  className,
  ...props
}) {
  return /* @__PURE__ */ jsx(
    AvatarPrimitive.Root,
    {
      "data-slot": "avatar",
      className: cn(
        "relative flex size-8 shrink-0 overflow-hidden rounded-full",
        className
      ),
      ...props
    }
  );
}
function AvatarImage({
  className,
  ...props
}) {
  return /* @__PURE__ */ jsx(
    AvatarPrimitive.Image,
    {
      "data-slot": "avatar-image",
      className: cn("aspect-square size-full", className),
      ...props
    }
  );
}
function AvatarFallback({
  className,
  ...props
}) {
  return /* @__PURE__ */ jsx(
    AvatarPrimitive.Fallback,
    {
      "data-slot": "avatar-fallback",
      className: cn(
        "bg-muted flex size-full items-center justify-center rounded-full",
        className
      ),
      ...props
    }
  );
}
function Separator({
  className,
  orientation = "horizontal",
  decorative = true,
  ...props
}) {
  return /* @__PURE__ */ jsx(
    SeparatorPrimitive.Root,
    {
      "data-slot": "separator-root",
      decorative,
      orientation,
      className: cn(
        "bg-border shrink-0 data-[orientation=horizontal]:h-px data-[orientation=horizontal]:w-full data-[orientation=vertical]:h-full data-[orientation=vertical]:w-px",
        className
      ),
      ...props
    }
  );
}
function UserMenu({
  name,
  email,
  avatarUrl
}) {
  return /* @__PURE__ */ jsxs(DropdownMenu, { children: [
    /* @__PURE__ */ jsx(DropdownMenuTrigger, { asChild: true, children: /* @__PURE__ */ jsxs(Avatar, { className: "size-8 cursor-pointer rounded-lg", children: [
      /* @__PURE__ */ jsx(AvatarImage, { src: avatarUrl ?? void 0 }),
      /* @__PURE__ */ jsx(AvatarFallback, { children: name.slice(0, 2) })
    ] }) }),
    /* @__PURE__ */ jsxs(DropdownMenuContent, { className: "w-56", children: [
      /* @__PURE__ */ jsxs(DropdownMenuLabel, { className: "grid flex-1 text-left text-sm leading-tight", children: [
        /* @__PURE__ */ jsx("span", { className: "truncate font-semibold", children: name }),
        /* @__PURE__ */ jsx("span", { className: "truncate text-xs", children: email })
      ] }),
      /* @__PURE__ */ jsx(DropdownMenuSeparator, {}),
      /* @__PURE__ */ jsx(DropdownMenuItem, { asChild: true, children: /* @__PURE__ */ jsx(SheetClose, { asChild: true, children: /* @__PURE__ */ jsxs(Link, { to: "#", viewTransition: true, children: [
        /* @__PURE__ */ jsx(HomeIcon, { className: "size-4" }),
        "Dashboard"
      ] }) }) }),
      /* @__PURE__ */ jsx(DropdownMenuItem, { asChild: true, children: /* @__PURE__ */ jsx(SheetClose, { asChild: true, children: /* @__PURE__ */ jsxs(Link, { to: "#", viewTransition: true, children: [
        /* @__PURE__ */ jsx(LogOutIcon, { className: "size-4" }),
        "Log out"
      ] }) }) })
    ] })
  ] });
}
function AuthButtons() {
  return /* @__PURE__ */ jsxs(Fragment, { children: [
    /* @__PURE__ */ jsx(Button, { variant: "ghost", asChild: true, children: /* @__PURE__ */ jsx(SheetClose, { asChild: true, children: /* @__PURE__ */ jsx(Link, { to: "/login", viewTransition: true, children: "Sign in" }) }) }),
    /* @__PURE__ */ jsx(Button, { variant: "default", asChild: true, children: /* @__PURE__ */ jsx(SheetClose, { asChild: true, children: /* @__PURE__ */ jsx(Link, { to: "/login", viewTransition: true, children: "Sign up" }) }) })
  ] });
}
function Actions() {
  return /* @__PURE__ */ jsxs(Fragment, { children: [
    /* @__PURE__ */ jsxs(DropdownMenu, { children: [
      /* @__PURE__ */ jsx(DropdownMenuTrigger, { asChild: true, className: "cursor-pointer", children: /* @__PURE__ */ jsx(Button, { variant: "ghost", size: "icon", children: /* @__PURE__ */ jsx(CogIcon, { className: "size-4" }) }) }),
      /* @__PURE__ */ jsxs(DropdownMenuContent, { align: "end", children: [
        /* @__PURE__ */ jsx(DropdownMenuItem, { asChild: true, children: /* @__PURE__ */ jsx(SheetClose, { asChild: true, children: /* @__PURE__ */ jsx(Link, { to: "/debug/sentry", viewTransition: true, children: "Sentry" }) }) }),
        /* @__PURE__ */ jsx(DropdownMenuItem, { asChild: true, children: /* @__PURE__ */ jsx(SheetClose, { asChild: true, children: /* @__PURE__ */ jsx(Link, { to: "/debug/analytics", viewTransition: true, children: "Google Tag" }) }) })
      ] })
    ] }),
    /* @__PURE__ */ jsx(ThemeSwitcher, {}),
    /* @__PURE__ */ jsx(LangSwitcher, {})
  ] });
}
function NavigationBar({
  name,
  email,
  avatarUrl,
  loading
}) {
  const { t } = useTranslation();
  return /* @__PURE__ */ jsx(
    "nav",
    {
      className: "mx-auto flex h-16 w-full items-center justify-between border-b px-5 shadow-xs backdrop-blur-lg transition-opacity md:px-10",
      children: /* @__PURE__ */ jsxs("div", { className: "mx-auto flex h-full w-full max-w-screen-2xl items-center justify-between py-3", children: [
        /* @__PURE__ */ jsx(Link, { to: "/", children: /* @__PURE__ */ jsx("h1", { className: "text-lg font-extrabold", children: t("home.title") }) }),
        /* @__PURE__ */ jsxs("div", { className: "hidden h-full items-center gap-5 md:flex", children: [
          /* @__PURE__ */ jsx(
            Link,
            {
              to: "/",
              viewTransition: true,
              className: "text-muted-foreground hover:text-foreground text-sm transition-colors",
              children: "Home"
            }
          ),
          /* @__PURE__ */ jsx(Separator, { orientation: "vertical" }),
          /* @__PURE__ */ jsx(Actions, {}),
          /* @__PURE__ */ jsx(Separator, { orientation: "vertical" }),
          loading ? (
            // Loading state with skeleton placeholder
            /* @__PURE__ */ jsx("div", { className: "flex items-center", children: /* @__PURE__ */ jsx("div", { className: "bg-muted-foreground/20 size-8 animate-pulse rounded-lg" }) })
          ) : /* @__PURE__ */ jsx(Fragment, { children: name ? (
            // Authenticated state with user menu
            /* @__PURE__ */ jsx(UserMenu, { name, email, avatarUrl })
          ) : (
            // Unauthenticated state with auth buttons
            /* @__PURE__ */ jsx(AuthButtons, {})
          ) })
        ] }),
        /* @__PURE__ */ jsx(SheetTrigger, { className: "size-6 md:hidden", children: /* @__PURE__ */ jsx(MenuIcon, {}) }),
        /* @__PURE__ */ jsxs(SheetContent, { children: [
          /* @__PURE__ */ jsx(SheetHeader, { children: /* @__PURE__ */ jsx(SheetClose, { asChild: true, children: /* @__PURE__ */ jsx(Link, { to: "/", children: "Home" }) }) }),
          loading ? /* @__PURE__ */ jsx("div", { className: "flex items-center", children: /* @__PURE__ */ jsx("div", { className: "bg-muted-foreground h-4 w-24 animate-pulse rounded-full" }) }) : /* @__PURE__ */ jsx(SheetFooter, { children: name ? /* @__PURE__ */ jsxs("div", { className: "grid grid-cols-3", children: [
            /* @__PURE__ */ jsx("div", { className: "col-span-2 flex w-full justify-between", children: /* @__PURE__ */ jsx(Actions, {}) }),
            /* @__PURE__ */ jsx("div", { className: "flex justify-end", children: /* @__PURE__ */ jsx(UserMenu, { name, email, avatarUrl }) })
          ] }) : /* @__PURE__ */ jsxs("div", { className: "flex flex-col gap-5", children: [
            /* @__PURE__ */ jsx("div", { className: "flex justify-between", children: /* @__PURE__ */ jsx(Actions, {}) }),
            /* @__PURE__ */ jsx("div", { className: "grid grid-cols-2 gap-2", children: /* @__PURE__ */ jsx(AuthButtons, {}) })
          ] }) })
        ] })
      ] })
    }
  );
}
async function loader$6({
  request
}) {
  return {};
}
const navigation_layout = withComponentProps(function NavigationLayout({
  loaderData
}) {
  return /* @__PURE__ */ jsxs("div", {
    className: "flex min-h-screen flex-col justify-between",
    children: [/* @__PURE__ */ jsx(NavigationBar, {
      loading: false
    }), /* @__PURE__ */ jsx("div", {
      className: "mx-auto my-16 w-full max-w-screen-2xl px-5 md:my-32",
      children: /* @__PURE__ */ jsx(Outlet, {})
    }), /* @__PURE__ */ jsx(Footer, {})]
  });
});
const route8 = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: navigation_layout,
  loader: loader$6
}, Symbol.toStringTag, { value: "Module" }));
const meta$7 = ({
  data: data2
}) => {
  return [{
    title: data2 == null ? void 0 : data2.title
  }, {
    name: "description",
    content: data2 == null ? void 0 : data2.subtitle
  }];
};
async function loader$5({
  request
}) {
  const t = await i18next.getFixedT(request);
  return {
    title: t("home.title"),
    subtitle: t("home.subtitle")
  };
}
const home = withComponentProps(function Home() {
  const {
    t
  } = useTranslation();
  return /* @__PURE__ */ jsxs("div", {
    className: "flex flex-col items-center justify-center gap-2.5",
    children: [/* @__PURE__ */ jsx("h1", {
      className: "text-4xl font-extrabold tracking-tight lg:text-6xl",
      children: t("home.title")
    }), /* @__PURE__ */ jsx("h2", {
      className: "text-2xl",
      children: t("home.subtitle")
    })]
  });
});
const route9 = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: home,
  loader: loader$5,
  meta: meta$7
}, Symbol.toStringTag, { value: "Module" }));
const meta$6 = () => {
  return [{
    title: `Server Error | ${void 0}`
  }];
};
const error = withComponentProps(function ErrorPage() {
  const [searchParams] = useSearchParams();
  const errorCode = searchParams.get("error_code");
  const errorDescription = searchParams.get("error_description");
  return /* @__PURE__ */ jsxs("div", {
    className: "flex flex-col items-center justify-center gap-2",
    children: [/* @__PURE__ */ jsx("h1", {
      className: "text-3xl font-semibold text-red-700",
      children: "Error"
    }), /* @__PURE__ */ jsxs("p", {
      className: "text-muted-foreground",
      children: ["Error code: ", errorCode]
    }), /* @__PURE__ */ jsx("p", {
      className: "text-muted-foreground",
      children: errorDescription
    }), /* @__PURE__ */ jsx(Button, {
      variant: "link",
      asChild: true,
      children: /* @__PURE__ */ jsx(Link, {
        to: "/",
        children: "Go to home →"
      })
    })]
  });
});
const route10 = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: error,
  meta: meta$6
}, Symbol.toStringTag, { value: "Module" }));
const firebaseConfig = {
  apiKey: "AIzaSyBl59sRmxoYoDK1SnWmiYqFRBYpzg3Y384",
  authDomain: "cclab-4ec42.firebaseapp.com",
  projectId: "cclab-4ec42",
  storageBucket: "cclab-4ec42.firebasestorage.app",
  messagingSenderId: "983598640244",
  appId: "1:983598640244:web:22a41f52f1ef918e9bb521",
  measurementId: "G-GDEGHRKHR1"
};
let app;
let auth;
let db;
if (!getApps().length) {
  app = initializeApp(firebaseConfig);
} else {
  app = getApp();
}
auth = getAuth(app);
db = getFirestore(app);
async function loader$4({
  request
}) {
  return {};
}
const public_layout = withComponentProps(function PublicLayout() {
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      if (user) {
        navigate("/dashboard");
      }
      setLoading(false);
    });
    return () => unsubscribe();
  }, [navigate]);
  if (loading) {
    return /* @__PURE__ */ jsx("div", {
      className: "flex h-screen items-center justify-center",
      children: "Loading..."
    });
  }
  return /* @__PURE__ */ jsx(Outlet, {});
});
const route11 = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: public_layout,
  loader: loader$4
}, Symbol.toStringTag, { value: "Module" }));
async function signIn(email, password) {
  try {
    const userCredential = await signInWithEmailAndPassword(auth, email, password);
    const user = userCredential.user;
    const userDocRef = doc(db, "users", user.uid);
    const userDoc = await getDoc(userDocRef);
    if (!userDoc.exists()) {
      await signOut$1(auth);
      throw new Error("Access denied: User profile not found.");
    }
    const userData = userDoc.data();
    const role = userData == null ? void 0 : userData.role;
    const church_id = userData == null ? void 0 : userData.church_id;
    if (role === "super-admin") {
    } else if (role === "admin") {
      if (!church_id) {
        await signOut$1(auth);
        throw new Error("Access denied: Admin account must be linked to a church.");
      }
    } else {
      await signOut$1(auth);
      throw new Error("Access denied: You do not have administrator privileges.");
    }
    const token = await user.getIdToken();
    return { user, token };
  } catch (error2) {
    console.error("Error signing in", error2);
    throw error2;
  }
}
async function signOut() {
  try {
    await signOut$1(auth);
  } catch (error2) {
    console.error("Error signing out", error2);
    throw error2;
  }
}
function Input({ className, type, ...props }) {
  return /* @__PURE__ */ jsx(
    "input",
    {
      type,
      "data-slot": "input",
      className: cn(
        "file:text-foreground placeholder:text-muted-foreground selection:bg-primary selection:text-primary-foreground dark:bg-input/30 border-input flex h-9 w-full min-w-0 rounded-md border bg-transparent px-3 py-1 text-base shadow-xs transition-[color,box-shadow] outline-none file:inline-flex file:h-7 file:border-0 file:bg-transparent file:text-sm file:font-medium disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm",
        "focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]",
        "aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
        className
      ),
      ...props
    }
  );
}
function Label({
  className,
  ...props
}) {
  return /* @__PURE__ */ jsx(
    LabelPrimitive.Root,
    {
      "data-slot": "label",
      className: cn(
        "flex items-center gap-2 text-sm leading-none font-medium select-none group-data-[disabled=true]:pointer-events-none group-data-[disabled=true]:opacity-50 peer-disabled:cursor-not-allowed peer-disabled:opacity-50",
        className
      ),
      ...props
    }
  );
}
const meta$5 = () => {
  return [{
    title: "Login | Admin Web"
  }];
};
const login = withComponentProps(function Login() {
  const navigate = useNavigate();
  const [isSubmitting, setIsSubmitting] = useState(false);
  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);
    const formData = new FormData(e.currentTarget);
    const email = formData.get("email");
    const password = formData.get("password");
    try {
      await signIn(email, password);
      toast.success("로그인 성공! 대시보드로 이동합니다.");
      setTimeout(() => {
        navigate("/dashboard");
      }, 500);
    } catch (error2) {
      toast.error(error2.message || "Invalid credentials");
    } finally {
      setIsSubmitting(false);
    }
  };
  return /* @__PURE__ */ jsx("div", {
    className: "flex min-h-screen items-center justify-center px-4 py-12 sm:px-6 lg:px-8",
    children: /* @__PURE__ */ jsxs("div", {
      className: "w-full max-w-md space-y-8",
      children: [/* @__PURE__ */ jsx("div", {
        children: /* @__PURE__ */ jsx("h2", {
          className: "mt-6 text-center text-3xl font-bold tracking-tight text-gray-900 dark:text-gray-100",
          children: "Sign in to Admin Web"
        })
      }), /* @__PURE__ */ jsxs("form", {
        onSubmit: handleSubmit,
        className: "mt-8 space-y-6",
        children: [/* @__PURE__ */ jsxs("div", {
          className: "-space-y-px rounded-md shadow-sm",
          children: [/* @__PURE__ */ jsxs("div", {
            className: "mb-4",
            children: [/* @__PURE__ */ jsx(Label, {
              htmlFor: "email-address",
              className: "sr-only",
              children: "Email address"
            }), /* @__PURE__ */ jsx(Input, {
              id: "email-address",
              name: "email",
              type: "email",
              autoComplete: "email",
              required: true,
              className: "relative block w-full appearance-none rounded-none rounded-t-md border px-3 py-2 focus:z-10 focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm",
              placeholder: "Email address"
            })]
          }), /* @__PURE__ */ jsxs("div", {
            children: [/* @__PURE__ */ jsx(Label, {
              htmlFor: "password",
              className: "sr-only",
              children: "Password"
            }), /* @__PURE__ */ jsx(Input, {
              id: "password",
              name: "password",
              type: "password",
              autoComplete: "current-password",
              required: true,
              className: "relative block w-full appearance-none rounded-none rounded-b-md border px-3 py-2 focus:z-10 focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm",
              placeholder: "Password"
            })]
          })]
        }), /* @__PURE__ */ jsx("div", {
          children: /* @__PURE__ */ jsx(Button, {
            type: "submit",
            disabled: isSubmitting,
            className: "group relative flex w-full justify-center py-2 px-4 text-sm font-medium",
            children: isSubmitting ? "Signing in..." : "Sign in"
          })
        })]
      })]
    })
  });
});
const route12 = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: login,
  meta: meta$5
}, Symbol.toStringTag, { value: "Module" }));
function Sidebar({ className }) {
  return /* @__PURE__ */ jsx("div", { className: cn("pb-12 min-h-screen border-r bg-background", className), children: /* @__PURE__ */ jsxs("div", { className: "space-y-4 py-4", children: [
    /* @__PURE__ */ jsxs("div", { className: "px-3 py-2", children: [
      /* @__PURE__ */ jsx("h2", { className: "mb-2 px-4 text-lg font-semibold tracking-tight", children: "Admin Web" }),
      /* @__PURE__ */ jsxs("div", { className: "space-y-1", children: [
        /* @__PURE__ */ jsx(NavItem, { to: "/dashboard", icon: LayoutDashboard, children: "Dashboard" }),
        /* @__PURE__ */ jsx(NavItem, { to: "/members", icon: Users, children: "Users" }),
        /* @__PURE__ */ jsx(NavItem, { to: "/groups", icon: Group, children: "Groups" }),
        /* @__PURE__ */ jsx(NavItem, { to: "/goals", icon: Target, children: "Goals" })
      ] })
    ] }),
    /* @__PURE__ */ jsxs("div", { className: "px-3 py-2", children: [
      /* @__PURE__ */ jsx("h2", { className: "mb-2 px-4 text-lg font-semibold tracking-tight", children: "Settings" }),
      /* @__PURE__ */ jsx("div", { className: "space-y-1", children: /* @__PURE__ */ jsx(NavItem, { to: "/settings", icon: Settings, children: "Settings" }) })
    ] })
  ] }) });
}
function NavItem({ to, icon: Icon, children }) {
  return /* @__PURE__ */ jsxs(
    NavLink,
    {
      to,
      className: ({ isActive }) => cn(
        "flex items-center rounded-md px-3 py-2 text-sm font-medium hover:bg-accent hover:text-accent-foreground transition-colors",
        isActive ? "bg-accent text-accent-foreground" : "text-muted-foreground"
      ),
      children: [
        /* @__PURE__ */ jsx(Icon, { className: "mr-2 h-4 w-4" }),
        children
      ]
    }
  );
}
async function loader$3({
  request
}) {
  return {};
}
const private_layout = withComponentProps(function PrivateLayout() {
  var _a;
  const [user, setUser] = useState(auth.currentUser);
  const [loading, setLoading] = useState(true);
  useNavigation();
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
      setUser(currentUser);
      setLoading(false);
      if (!currentUser) {
        window.location.href = "/login";
      }
    });
    return () => unsubscribe();
  }, []);
  if (loading) {
    return /* @__PURE__ */ jsx("div", {
      className: "flex h-screen items-center justify-center",
      children: "Loading..."
    });
  }
  if (!user) {
    return null;
  }
  return /* @__PURE__ */ jsxs("div", {
    className: "flex min-h-screen flex-col",
    children: [/* @__PURE__ */ jsx(NavigationBar, {
      name: user.displayName || ((_a = user.email) == null ? void 0 : _a.split("@")[0]) || "Admin",
      email: user.email || "",
      avatarUrl: user.photoURL,
      loading: false
    }), /* @__PURE__ */ jsxs("div", {
      className: "flex flex-1",
      children: [/* @__PURE__ */ jsx("aside", {
        className: "hidden w-64 border-r bg-background md:block",
        children: /* @__PURE__ */ jsx(Sidebar, {})
      }), /* @__PURE__ */ jsx("main", {
        className: "flex-1",
        children: /* @__PURE__ */ jsx("div", {
          className: "h-full px-4 py-6 lg:px-8",
          children: /* @__PURE__ */ jsx(Outlet, {})
        })
      })]
    }), /* @__PURE__ */ jsx(Footer, {})]
  });
});
const route13 = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: private_layout,
  loader: loader$3
}, Symbol.toStringTag, { value: "Module" }));
function StatsOverview({ memberCount, groupCount, chaptersRead, completionRate }) {
  return /* @__PURE__ */ jsxs("div", { className: "grid gap-4 md:grid-cols-2 lg:grid-cols-4", children: [
    /* @__PURE__ */ jsxs("div", { className: "rounded-xl border bg-card text-card-foreground shadow p-6", children: [
      /* @__PURE__ */ jsxs("div", { className: "flex flex-row items-center justify-between space-y-0 pb-2", children: [
        /* @__PURE__ */ jsx("div", { className: "text-sm font-medium", children: "Total Members" }),
        /* @__PURE__ */ jsx(Users, { className: "h-4 w-4 text-muted-foreground" })
      ] }),
      /* @__PURE__ */ jsx("div", { className: "text-2xl font-bold", children: memberCount }),
      /* @__PURE__ */ jsx("p", { className: "text-xs text-muted-foreground", children: "+20.1% from last month" })
    ] }),
    /* @__PURE__ */ jsxs("div", { className: "rounded-xl border bg-card text-card-foreground shadow p-6", children: [
      /* @__PURE__ */ jsxs("div", { className: "flex flex-row items-center justify-between space-y-0 pb-2", children: [
        /* @__PURE__ */ jsx("div", { className: "text-sm font-medium", children: "Active Groups" }),
        /* @__PURE__ */ jsx(Crown, { className: "h-4 w-4 text-muted-foreground" })
      ] }),
      /* @__PURE__ */ jsx("div", { className: "text-2xl font-bold", children: groupCount }),
      /* @__PURE__ */ jsx("p", { className: "text-xs text-muted-foreground", children: "+3 new groups" })
    ] }),
    /* @__PURE__ */ jsxs("div", { className: "rounded-xl border bg-card text-card-foreground shadow p-6", children: [
      /* @__PURE__ */ jsxs("div", { className: "flex flex-row items-center justify-between space-y-0 pb-2", children: [
        /* @__PURE__ */ jsx("div", { className: "text-sm font-medium", children: "Chapters Read" }),
        /* @__PURE__ */ jsx(BookOpen, { className: "h-4 w-4 text-muted-foreground" })
      ] }),
      /* @__PURE__ */ jsx("div", { className: "text-2xl font-bold", children: chaptersRead.toLocaleString() }),
      /* @__PURE__ */ jsx("p", { className: "text-xs text-muted-foreground", children: "+12% from last week" })
    ] }),
    /* @__PURE__ */ jsxs("div", { className: "rounded-xl border bg-card text-card-foreground shadow p-6", children: [
      /* @__PURE__ */ jsxs("div", { className: "flex flex-row items-center justify-between space-y-0 pb-2", children: [
        /* @__PURE__ */ jsx("div", { className: "text-sm font-medium", children: "Completion Rate" }),
        /* @__PURE__ */ jsx(
          "svg",
          {
            xmlns: "http://www.w3.org/2000/svg",
            viewBox: "0 0 24 24",
            fill: "none",
            stroke: "currentColor",
            strokeLinecap: "round",
            strokeLinejoin: "round",
            strokeWidth: "2",
            className: "h-4 w-4 text-muted-foreground",
            children: /* @__PURE__ */ jsx("path", { d: "M22 12h-4l-3 9L9 3l-3 9H2" })
          }
        )
      ] }),
      /* @__PURE__ */ jsxs("div", { className: "text-2xl font-bold", children: [
        completionRate,
        "%"
      ] }),
      /* @__PURE__ */ jsx("p", { className: "text-xs text-muted-foreground", children: "+2.4% from last week" })
    ] })
  ] });
}
function ReadingProgressChart({ data: data2 }) {
  return /* @__PURE__ */ jsxs("div", { className: "rounded-xl border bg-card text-card-foreground shadow col-span-4", children: [
    /* @__PURE__ */ jsxs("div", { className: "p-6 flex flex-col space-y-0.5", children: [
      /* @__PURE__ */ jsx("h3", { className: "font-semibold leading-none tracking-tight", children: "Weekly Reading Progress" }),
      /* @__PURE__ */ jsx("p", { className: "text-sm text-muted-foreground", children: "Chapters read over time" })
    ] }),
    /* @__PURE__ */ jsx("div", { className: "p-6 pt-0 pl-2", children: /* @__PURE__ */ jsx(ResponsiveContainer, { width: "100%", height: 350, children: /* @__PURE__ */ jsxs(LineChart, { data: data2, children: [
      /* @__PURE__ */ jsx(
        XAxis,
        {
          dataKey: "name",
          stroke: "#888888",
          fontSize: 12,
          tickLine: false,
          axisLine: false
        }
      ),
      /* @__PURE__ */ jsx(
        YAxis,
        {
          stroke: "#888888",
          fontSize: 12,
          tickLine: false,
          axisLine: false,
          tickFormatter: (value) => `${value}`
        }
      ),
      /* @__PURE__ */ jsx(CartesianGrid, { strokeDasharray: "3 3", vertical: false }),
      /* @__PURE__ */ jsx(
        Tooltip,
        {
          contentStyle: { borderRadius: "8px", border: "1px solid #e2e8f0" }
        }
      ),
      /* @__PURE__ */ jsx(
        Line,
        {
          type: "monotone",
          dataKey: "total",
          stroke: "#8884d8",
          strokeWidth: 2,
          activeDot: { r: 8 }
        }
      )
    ] }) }) })
  ] });
}
function GroupParticipationChart({ data: data2 }) {
  return /* @__PURE__ */ jsxs("div", { className: "rounded-xl border bg-card text-card-foreground shadow col-span-3", children: [
    /* @__PURE__ */ jsxs("div", { className: "p-6 flex flex-col space-y-0.5", children: [
      /* @__PURE__ */ jsx("h3", { className: "font-semibold leading-none tracking-tight", children: "Group Participation" }),
      /* @__PURE__ */ jsx("p", { className: "text-sm text-muted-foreground", children: "Active members by group" })
    ] }),
    /* @__PURE__ */ jsx("div", { className: "p-6 pt-0 pl-2", children: /* @__PURE__ */ jsx(ResponsiveContainer, { width: "100%", height: 350, children: /* @__PURE__ */ jsxs(BarChart, { data: data2, children: [
      /* @__PURE__ */ jsx(
        XAxis,
        {
          dataKey: "name",
          stroke: "#888888",
          fontSize: 12,
          tickLine: false,
          axisLine: false
        }
      ),
      /* @__PURE__ */ jsx(
        YAxis,
        {
          stroke: "#888888",
          fontSize: 12,
          tickLine: false,
          axisLine: false,
          tickFormatter: (value) => `${value}%`
        }
      ),
      /* @__PURE__ */ jsx(
        Tooltip,
        {
          cursor: { fill: "transparent" },
          contentStyle: { borderRadius: "8px", border: "1px solid #e2e8f0" }
        }
      ),
      /* @__PURE__ */ jsx(
        Bar,
        {
          dataKey: "rate",
          fill: "#adfa1d",
          radius: [4, 4, 0, 0]
        }
      )
    ] }) }) })
  ] });
}
async function fetchDashboardStats() {
  try {
    const usersColl = collection(db, "users");
    const snapshot = await getCountFromServer(usersColl);
    const memberCount = snapshot.data().count;
    const groupsColl = collection(db, "groups");
    const groupSnapshot = await getCountFromServer(groupsColl);
    const groupCount = groupSnapshot.data().count;
    const chaptersRead = 0;
    const completionRate = 0;
    return {
      memberCount,
      groupCount,
      chaptersRead,
      completionRate
    };
  } catch (error2) {
    console.error("Error fetching dashboard stats:", error2);
    return {
      memberCount: 0,
      groupCount: 0,
      chaptersRead: 0,
      completionRate: 0
    };
  }
}
const meta$4 = () => {
  return [{
    title: "Dashboard | Admin Web"
  }];
};
async function loader$2({
  request
}) {
  return {};
}
const dashboard = withComponentProps(function Dashboard() {
  const {
    t
  } = useTranslation();
  const [stats, setStats] = useState({
    memberCount: 0,
    groupCount: 0,
    chaptersRead: 0,
    completionRate: 0
  });
  useEffect(() => {
    fetchDashboardStats().then(setStats);
  }, []);
  const handleLogout = async () => {
    await signOut();
    window.location.href = "/login";
  };
  const readingData = [{
    name: "Jan",
    total: 1200
  }, {
    name: "Feb",
    total: 2100
  }, {
    name: "Mar",
    total: 3400
  }, {
    name: "Apr",
    total: 4521
  }, {
    name: "May",
    total: 5100
  }, {
    name: "Jun",
    total: 6e3
  }];
  const groupData = [{
    name: "Sarang",
    rate: 85
  }, {
    name: "Joy",
    rate: 65
  }, {
    name: "Peace",
    rate: 90
  }, {
    name: "Hope",
    rate: 45
  }, {
    name: "Faith",
    rate: 70
  }];
  return /* @__PURE__ */ jsxs("div", {
    className: "flex-1 space-y-4 p-8 pt-6",
    children: [/* @__PURE__ */ jsxs("div", {
      className: "flex items-center justify-between space-y-2",
      children: [/* @__PURE__ */ jsx("h2", {
        className: "text-3xl font-bold tracking-tight",
        children: "Dashboard"
      }), /* @__PURE__ */ jsx("div", {
        className: "flex items-center space-x-2",
        children: /* @__PURE__ */ jsx(Button, {
          variant: "outline",
          onClick: handleLogout,
          children: "Sign out"
        })
      })]
    }), /* @__PURE__ */ jsxs("div", {
      className: "space-y-4",
      children: [/* @__PURE__ */ jsx(StatsOverview, {
        memberCount: stats.memberCount,
        groupCount: stats.groupCount,
        chaptersRead: stats.chaptersRead,
        completionRate: stats.completionRate
      }), /* @__PURE__ */ jsxs("div", {
        className: "grid gap-4 md:grid-cols-2 lg:grid-cols-7",
        children: [/* @__PURE__ */ jsx(ReadingProgressChart, {
          data: readingData
        }), /* @__PURE__ */ jsx(GroupParticipationChart, {
          data: groupData
        })]
      })]
    })]
  });
});
const route14 = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: dashboard,
  loader: loader$2,
  meta: meta$4
}, Symbol.toStringTag, { value: "Module" }));
const meta$3 = () => {
  return [{
    title: "Members | Admin Web"
  }];
};
const memberList = withComponentProps(function MemberList() {
  return /* @__PURE__ */ jsxs("div", {
    className: "flex-1 space-y-4 p-8 pt-6",
    children: [/* @__PURE__ */ jsx("h2", {
      className: "text-3xl font-bold tracking-tight",
      children: "Members"
    }), /* @__PURE__ */ jsx("p", {
      children: "Member management feature coming soon."
    })]
  });
});
const route15 = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: memberList,
  meta: meta$3
}, Symbol.toStringTag, { value: "Module" }));
const meta$2 = () => {
  return [{
    title: "Goals | Admin Web"
  }];
};
const goalList = withComponentProps(function GoalList() {
  return /* @__PURE__ */ jsxs("div", {
    className: "flex-1 space-y-4 p-8 pt-6",
    children: [/* @__PURE__ */ jsx("h2", {
      className: "text-3xl font-bold tracking-tight",
      children: "Goals"
    }), /* @__PURE__ */ jsx("p", {
      children: "Goal management feature coming soon."
    })]
  });
});
const route16 = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: goalList,
  meta: meta$2
}, Symbol.toStringTag, { value: "Module" }));
function GroupCard({ id, name, leaderName, memberCount }) {
  return /* @__PURE__ */ jsxs("div", { className: "rounded-lg border bg-card text-card-foreground shadow-sm p-6 flex flex-col justify-between h-[180px]", children: [
    /* @__PURE__ */ jsxs("div", { children: [
      /* @__PURE__ */ jsxs("div", { className: "flex items-center justify-between", children: [
        /* @__PURE__ */ jsx("h3", { className: "text-xl font-bold tracking-tight", children: name }),
        /* @__PURE__ */ jsxs("div", { className: "bg-primary/10 text-primary px-2.5 py-0.5 rounded-full text-xs font-medium flex items-center gap-1", children: [
          /* @__PURE__ */ jsx(Users, { className: "h-3 w-3" }),
          memberCount
        ] })
      ] }),
      /* @__PURE__ */ jsxs("div", { className: "mt-4 flex items-center gap-2 text-sm text-muted-foreground", children: [
        /* @__PURE__ */ jsx(User, { className: "h-4 w-4" }),
        /* @__PURE__ */ jsxs("span", { children: [
          "Leader: ",
          /* @__PURE__ */ jsx("span", { className: "font-medium text-foreground", children: leaderName })
        ] })
      ] })
    ] }),
    /* @__PURE__ */ jsx("div", { className: "mt-4", children: /* @__PURE__ */ jsx(Button, { asChild: true, variant: "outline", className: "w-full justify-between group", children: /* @__PURE__ */ jsxs(Link, { to: `/groups/${id}`, children: [
      "Manage Group",
      /* @__PURE__ */ jsx(ArrowRight, { className: "h-4 w-4 ml-2 transition-transform group-hover:translate-x-1" })
    ] }) }) })
  ] });
}
async function fetchGroups() {
  try {
    const groupsColl = collection(db, "groups");
    const snapshot = await getDocs(groupsColl);
    return snapshot.docs.map((doc2) => {
      const data2 = doc2.data();
      return {
        ...data2,
        // Spread first to avoid overwriting normalized fields
        id: doc2.id,
        name: data2.name || data2.groupName || data2.group_name || "Unnamed Group",
        leaderName: data2.leaderName || data2.leader_name || "Unknown Leader",
        memberCount: data2.memberCount || data2.member_count || 0
      };
    });
  } catch (error2) {
    console.error("Error fetching groups:", error2);
    return [];
  }
}
async function fetchGroupById(groupId) {
  try {
    const groupDoc = doc(db, "groups", groupId);
    const snapshot = await getDoc(groupDoc);
    if (snapshot.exists()) {
      const data2 = snapshot.data();
      console.log("Fetched Group Data:", data2);
      return {
        ...data2,
        // Spread first
        id: snapshot.id,
        name: data2.name || data2.groupName || data2.group_name || "Unnamed Group",
        leaderName: data2.leaderName || data2.leader_name || "Unknown Leader",
        memberCount: data2.memberCount || data2.member_count || 0
      };
    }
    return null;
  } catch (error2) {
    console.error("Error fetching group details:", error2);
    return null;
  }
}
async function fetchGroupMembers(groupId) {
  try {
    const usersColl = collection(db, "users");
    const q = query(usersColl, where("groupId", "==", groupId));
    const snapshot = await getDocs(q);
    return snapshot.docs.map((doc2) => ({
      id: doc2.id,
      name: doc2.data().displayName || "Unknown",
      email: doc2.data().email || "",
      role: doc2.data().role || "Member",
      avatarUrl: doc2.data().photoURL
    }));
  } catch (error2) {
    console.error("Error fetching group members:", error2);
    return [];
  }
}
const meta$1 = () => {
  return [{
    title: "Groups | Admin Web"
  }];
};
async function loader$1({
  request
}) {
  return {};
}
const groupList = withComponentProps(function GroupList() {
  const [groups, setGroups] = useState([]);
  useEffect(() => {
    fetchGroups().then(setGroups);
  }, []);
  return /* @__PURE__ */ jsxs("div", {
    className: "flex-1 space-y-8 p-8 pt-6",
    children: [/* @__PURE__ */ jsxs("div", {
      className: "flex items-center justify-between space-y-2",
      children: [/* @__PURE__ */ jsxs("div", {
        children: [/* @__PURE__ */ jsx("h2", {
          className: "text-3xl font-bold tracking-tight",
          children: "Small Groups"
        }), /* @__PURE__ */ jsx("p", {
          className: "text-muted-foreground",
          children: "Manage your church cells and groups here."
        })]
      }), /* @__PURE__ */ jsx("div", {
        className: "flex items-center space-x-2",
        children: /* @__PURE__ */ jsxs(Button, {
          children: [/* @__PURE__ */ jsx(Plus, {
            className: "mr-2 h-4 w-4"
          }), " Create Group"]
        })
      })]
    }), /* @__PURE__ */ jsx("div", {
      className: "grid gap-6 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4",
      children: groups.length === 0 ? /* @__PURE__ */ jsx("p", {
        className: "text-muted-foreground col-span-full",
        children: "No groups found."
      }) : groups.map((group) => /* @__PURE__ */ jsx(GroupCard, {
        id: group.id,
        name: group.name,
        leaderName: group.leaderName,
        memberCount: group.memberCount
      }, group.id))
    })]
  });
});
const route17 = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: groupList,
  loader: loader$1,
  meta: meta$1
}, Symbol.toStringTag, { value: "Module" }));
function Table({ className, ...props }) {
  return /* @__PURE__ */ jsx(
    "div",
    {
      "data-slot": "table-container",
      className: "relative w-full overflow-x-auto",
      children: /* @__PURE__ */ jsx(
        "table",
        {
          "data-slot": "table",
          className: cn("w-full caption-bottom text-sm", className),
          ...props
        }
      )
    }
  );
}
function TableHeader({ className, ...props }) {
  return /* @__PURE__ */ jsx(
    "thead",
    {
      "data-slot": "table-header",
      className: cn("[&_tr]:border-b", className),
      ...props
    }
  );
}
function TableBody({ className, ...props }) {
  return /* @__PURE__ */ jsx(
    "tbody",
    {
      "data-slot": "table-body",
      className: cn("[&_tr:last-child]:border-0", className),
      ...props
    }
  );
}
function TableRow({ className, ...props }) {
  return /* @__PURE__ */ jsx(
    "tr",
    {
      "data-slot": "table-row",
      className: cn(
        "hover:bg-muted/50 data-[state=selected]:bg-muted border-b transition-colors",
        className
      ),
      ...props
    }
  );
}
function TableHead({ className, ...props }) {
  return /* @__PURE__ */ jsx(
    "th",
    {
      "data-slot": "table-head",
      className: cn(
        "text-foreground h-10 px-2 text-left align-middle font-medium whitespace-nowrap [&:has([role=checkbox])]:pr-0 [&>[role=checkbox]]:translate-y-[2px]",
        className
      ),
      ...props
    }
  );
}
function TableCell({ className, ...props }) {
  return /* @__PURE__ */ jsx(
    "td",
    {
      "data-slot": "table-cell",
      className: cn(
        "p-2 align-middle whitespace-nowrap [&:has([role=checkbox])]:pr-0 [&>[role=checkbox]]:translate-y-[2px]",
        className
      ),
      ...props
    }
  );
}
function MemberTable({ members }) {
  return /* @__PURE__ */ jsx("div", { className: "rounded-md border", children: /* @__PURE__ */ jsxs(Table, { children: [
    /* @__PURE__ */ jsx(TableHeader, { children: /* @__PURE__ */ jsxs(TableRow, { children: [
      /* @__PURE__ */ jsx(TableHead, { className: "w-[100px]", children: "Profile" }),
      /* @__PURE__ */ jsx(TableHead, { children: "Name" }),
      /* @__PURE__ */ jsx(TableHead, { children: "Email" }),
      /* @__PURE__ */ jsx(TableHead, { children: "Role" })
    ] }) }),
    /* @__PURE__ */ jsx(TableBody, { children: members.length === 0 ? /* @__PURE__ */ jsx(TableRow, { children: /* @__PURE__ */ jsx(TableCell, { colSpan: 4, className: "h-24 text-center", children: "No members found." }) }) : members.map((member) => /* @__PURE__ */ jsxs(TableRow, { children: [
      /* @__PURE__ */ jsx(TableCell, { children: /* @__PURE__ */ jsxs(Avatar, { children: [
        /* @__PURE__ */ jsx(AvatarImage, { src: member.avatarUrl, alt: member.name }),
        /* @__PURE__ */ jsx(AvatarFallback, { children: member.name.substring(0, 2).toUpperCase() })
      ] }) }),
      /* @__PURE__ */ jsx(TableCell, { className: "font-medium", children: member.name }),
      /* @__PURE__ */ jsx(TableCell, { children: member.email }),
      /* @__PURE__ */ jsx(TableCell, { children: member.role })
    ] }, member.id)) })
  ] }) });
}
const meta = () => {
  return [{
    title: "Group Detail | Admin Web"
  }];
};
async function loader({
  params
}) {
  return {
    groupId: params.groupId
  };
}
const groupDetail = withComponentProps(function GroupDetail({
  loaderData
}) {
  const {
    groupId
  } = loaderData;
  const [group, setGroup] = useState(null);
  const [members, setMembers] = useState([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    async function loadData() {
      if (!groupId) return;
      const [groupData, membersData] = await Promise.all([fetchGroupById(groupId), fetchGroupMembers(groupId)]);
      setGroup(groupData);
      setMembers(membersData);
      setLoading(false);
    }
    loadData();
  }, [groupId]);
  if (loading) return /* @__PURE__ */ jsx("div", {
    className: "p-8",
    children: "Loading..."
  });
  if (!group) return /* @__PURE__ */ jsx("div", {
    className: "p-8",
    children: "Group not found"
  });
  return /* @__PURE__ */ jsxs("div", {
    className: "flex-1 space-y-8 p-8 pt-6",
    children: [/* @__PURE__ */ jsxs("div", {
      className: "flex items-center space-x-4",
      children: [/* @__PURE__ */ jsx(Button, {
        variant: "ghost",
        size: "icon",
        asChild: true,
        children: /* @__PURE__ */ jsx(Link, {
          to: "/groups",
          children: /* @__PURE__ */ jsx(ArrowLeft, {
            className: "h-5 w-5"
          })
        })
      }), /* @__PURE__ */ jsxs("div", {
        children: [/* @__PURE__ */ jsx("h2", {
          className: "text-3xl font-bold tracking-tight",
          children: group.name
        }), /* @__PURE__ */ jsxs("p", {
          className: "text-muted-foreground",
          children: ["Leader: ", group.leaderName]
        })]
      })]
    }), /* @__PURE__ */ jsxs("div", {
      className: "space-y-4",
      children: [/* @__PURE__ */ jsxs("div", {
        className: "flex items-center justify-between",
        children: [/* @__PURE__ */ jsx("h3", {
          className: "text-xl font-semibold",
          children: "Members"
        }), /* @__PURE__ */ jsx(Button, {
          variant: "outline",
          size: "sm",
          children: "Add Member"
        })]
      }), /* @__PURE__ */ jsx(MemberTable, {
        members
      })]
    })]
  });
});
const route18 = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: groupDetail,
  loader,
  meta
}, Symbol.toStringTag, { value: "Module" }));
const serverManifest = { "entry": { "module": "/assets/entry.client-BcKq0c1f.js", "imports": ["/assets/chunk-LSOULM7L-CE8sSiXH.js", "/assets/index-DwFH84ni.js", "/assets/context-CssrF-fD.js"], "css": [] }, "routes": { "root": { "id": "root", "parentId": void 0, "path": "", "index": void 0, "caseSensitive": void 0, "hasAction": false, "hasLoader": true, "hasClientAction": false, "hasClientLoader": false, "hasClientMiddleware": false, "hasErrorBoundary": true, "module": "/assets/root-DD_T-2nY.js", "imports": ["/assets/chunk-LSOULM7L-CE8sSiXH.js", "/assets/index-DwFH84ni.js", "/assets/context-CssrF-fD.js", "/assets/with-props-CP8Fb9K_.js", "/assets/useTranslation-DcJzacty.js", "/assets/sheet-BdVv5Cn4.js", "/assets/index-BXu9-RIU.js", "/assets/button-ZU_4EZ5Z.js", "/assets/index-mkzE_evR.js", "/assets/index-ll88vSaB.js", "/assets/createLucideIcon-ClctZlHb.js"], "css": ["/assets/root-Dz32h_Hq.css"], "clientActionModule": void 0, "clientLoaderModule": void 0, "clientMiddlewareModule": void 0, "hydrateFallbackModule": void 0 }, "core/screens/robots": { "id": "core/screens/robots", "parentId": "root", "path": "/robots.txt", "index": void 0, "caseSensitive": void 0, "hasAction": false, "hasLoader": true, "hasClientAction": false, "hasClientLoader": false, "hasClientMiddleware": false, "hasErrorBoundary": false, "module": "/assets/robots-l0sNRNKZ.js", "imports": [], "css": [], "clientActionModule": void 0, "clientLoaderModule": void 0, "clientMiddlewareModule": void 0, "hydrateFallbackModule": void 0 }, "core/screens/sitemap": { "id": "core/screens/sitemap", "parentId": "root", "path": "/sitemap.xml", "index": void 0, "caseSensitive": void 0, "hasAction": false, "hasLoader": true, "hasClientAction": false, "hasClientLoader": false, "hasClientMiddleware": false, "hasErrorBoundary": false, "module": "/assets/sitemap-l0sNRNKZ.js", "imports": [], "css": [], "clientActionModule": void 0, "clientLoaderModule": void 0, "clientMiddlewareModule": void 0, "hydrateFallbackModule": void 0 }, "features/links/screens/invite-redirect": { "id": "features/links/screens/invite-redirect", "parentId": "root", "path": "/invite/:code", "index": void 0, "caseSensitive": void 0, "hasAction": false, "hasLoader": false, "hasClientAction": false, "hasClientLoader": false, "hasClientMiddleware": false, "hasErrorBoundary": false, "module": "/assets/invite-redirect-CUGKzw8c.js", "imports": ["/assets/with-props-CP8Fb9K_.js", "/assets/chunk-LSOULM7L-CE8sSiXH.js", "/assets/createLucideIcon-ClctZlHb.js"], "css": [], "clientActionModule": void 0, "clientLoaderModule": void 0, "clientMiddlewareModule": void 0, "hydrateFallbackModule": void 0 }, "debug/sentry": { "id": "debug/sentry", "parentId": "root", "path": "/debug/sentry", "index": void 0, "caseSensitive": void 0, "hasAction": true, "hasLoader": false, "hasClientAction": false, "hasClientLoader": false, "hasClientMiddleware": false, "hasErrorBoundary": false, "module": "/assets/sentry-DSg-vLIu.js", "imports": ["/assets/with-props-CP8Fb9K_.js", "/assets/chunk-LSOULM7L-CE8sSiXH.js", "/assets/button-ZU_4EZ5Z.js"], "css": [], "clientActionModule": void 0, "clientLoaderModule": void 0, "clientMiddlewareModule": void 0, "hydrateFallbackModule": void 0 }, "debug/analytics": { "id": "debug/analytics", "parentId": "root", "path": "/debug/analytics", "index": void 0, "caseSensitive": void 0, "hasAction": false, "hasLoader": false, "hasClientAction": true, "hasClientLoader": false, "hasClientMiddleware": false, "hasErrorBoundary": false, "module": "/assets/analytics-B5Eh9bdy.js", "imports": ["/assets/with-props-CP8Fb9K_.js", "/assets/chunk-LSOULM7L-CE8sSiXH.js", "/assets/button-ZU_4EZ5Z.js", "/assets/createLucideIcon-ClctZlHb.js"], "css": [], "clientActionModule": void 0, "clientLoaderModule": void 0, "clientMiddlewareModule": void 0, "hydrateFallbackModule": void 0 }, "features/settings/api/set-theme": { "id": "features/settings/api/set-theme", "parentId": "root", "path": "/api/settings/theme", "index": void 0, "caseSensitive": void 0, "hasAction": true, "hasLoader": false, "hasClientAction": false, "hasClientLoader": false, "hasClientMiddleware": false, "hasErrorBoundary": false, "module": "/assets/set-theme-l0sNRNKZ.js", "imports": [], "css": [], "clientActionModule": void 0, "clientLoaderModule": void 0, "clientMiddlewareModule": void 0, "hydrateFallbackModule": void 0 }, "features/settings/api/set-locale": { "id": "features/settings/api/set-locale", "parentId": "root", "path": "/api/settings/locale", "index": void 0, "caseSensitive": void 0, "hasAction": true, "hasLoader": false, "hasClientAction": false, "hasClientLoader": false, "hasClientMiddleware": false, "hasErrorBoundary": false, "module": "/assets/set-locale-l0sNRNKZ.js", "imports": [], "css": [], "clientActionModule": void 0, "clientLoaderModule": void 0, "clientMiddlewareModule": void 0, "hydrateFallbackModule": void 0 }, "core/layouts/navigation.layout": { "id": "core/layouts/navigation.layout", "parentId": "root", "path": void 0, "index": void 0, "caseSensitive": void 0, "hasAction": false, "hasLoader": true, "hasClientAction": false, "hasClientLoader": false, "hasClientMiddleware": false, "hasErrorBoundary": false, "module": "/assets/navigation.layout-_tprQcaV.js", "imports": ["/assets/with-props-CP8Fb9K_.js", "/assets/chunk-LSOULM7L-CE8sSiXH.js", "/assets/navigation-bar-mylno3kM.js", "/assets/button-ZU_4EZ5Z.js", "/assets/sheet-BdVv5Cn4.js", "/assets/index-mkzE_evR.js", "/assets/index-ll88vSaB.js", "/assets/index-DwFH84ni.js", "/assets/createLucideIcon-ClctZlHb.js", "/assets/useTranslation-DcJzacty.js", "/assets/context-CssrF-fD.js", "/assets/avatar-Cm_O8PBu.js"], "css": [], "clientActionModule": void 0, "clientLoaderModule": void 0, "clientMiddlewareModule": void 0, "hydrateFallbackModule": void 0 }, "features/home/screens/home": { "id": "features/home/screens/home", "parentId": "core/layouts/navigation.layout", "path": void 0, "index": true, "caseSensitive": void 0, "hasAction": false, "hasLoader": true, "hasClientAction": false, "hasClientLoader": false, "hasClientMiddleware": false, "hasErrorBoundary": false, "module": "/assets/home-vIysjLu_.js", "imports": ["/assets/with-props-CP8Fb9K_.js", "/assets/chunk-LSOULM7L-CE8sSiXH.js", "/assets/useTranslation-DcJzacty.js", "/assets/context-CssrF-fD.js"], "css": [], "clientActionModule": void 0, "clientLoaderModule": void 0, "clientMiddlewareModule": void 0, "hydrateFallbackModule": void 0 }, "core/screens/error": { "id": "core/screens/error", "parentId": "core/layouts/navigation.layout", "path": "/error", "index": void 0, "caseSensitive": void 0, "hasAction": false, "hasLoader": false, "hasClientAction": false, "hasClientLoader": false, "hasClientMiddleware": false, "hasErrorBoundary": false, "module": "/assets/error-C6Kwyo4e.js", "imports": ["/assets/with-props-CP8Fb9K_.js", "/assets/chunk-LSOULM7L-CE8sSiXH.js", "/assets/button-ZU_4EZ5Z.js"], "css": [], "clientActionModule": void 0, "clientLoaderModule": void 0, "clientMiddlewareModule": void 0, "hydrateFallbackModule": void 0 }, "core/layouts/public.layout": { "id": "core/layouts/public.layout", "parentId": "root", "path": void 0, "index": void 0, "caseSensitive": void 0, "hasAction": false, "hasLoader": true, "hasClientAction": false, "hasClientLoader": false, "hasClientMiddleware": false, "hasErrorBoundary": false, "module": "/assets/public.layout-CuxOIC2W.js", "imports": ["/assets/with-props-CP8Fb9K_.js", "/assets/chunk-LSOULM7L-CE8sSiXH.js", "/assets/firebase-3OE0PJgJ.js"], "css": [], "clientActionModule": void 0, "clientLoaderModule": void 0, "clientMiddlewareModule": void 0, "hydrateFallbackModule": void 0 }, "features/auth/screens/login": { "id": "features/auth/screens/login", "parentId": "core/layouts/public.layout", "path": "/login", "index": void 0, "caseSensitive": void 0, "hasAction": false, "hasLoader": false, "hasClientAction": false, "hasClientLoader": false, "hasClientMiddleware": false, "hasErrorBoundary": false, "module": "/assets/login-gjPxU1q4.js", "imports": ["/assets/with-props-CP8Fb9K_.js", "/assets/chunk-LSOULM7L-CE8sSiXH.js", "/assets/index-BXu9-RIU.js", "/assets/auth-VcATNi_0.js", "/assets/button-ZU_4EZ5Z.js", "/assets/index-ll88vSaB.js", "/assets/index-DwFH84ni.js", "/assets/firebase-3OE0PJgJ.js"], "css": [], "clientActionModule": void 0, "clientLoaderModule": void 0, "clientMiddlewareModule": void 0, "hydrateFallbackModule": void 0 }, "core/layouts/private.layout": { "id": "core/layouts/private.layout", "parentId": "root", "path": void 0, "index": void 0, "caseSensitive": void 0, "hasAction": false, "hasLoader": true, "hasClientAction": false, "hasClientLoader": false, "hasClientMiddleware": false, "hasErrorBoundary": false, "module": "/assets/private.layout-CymlNiaZ.js", "imports": ["/assets/with-props-CP8Fb9K_.js", "/assets/chunk-LSOULM7L-CE8sSiXH.js", "/assets/firebase-3OE0PJgJ.js", "/assets/navigation-bar-mylno3kM.js", "/assets/button-ZU_4EZ5Z.js", "/assets/createLucideIcon-ClctZlHb.js", "/assets/users-CoGeGUwu.js", "/assets/sheet-BdVv5Cn4.js", "/assets/index-mkzE_evR.js", "/assets/index-ll88vSaB.js", "/assets/index-DwFH84ni.js", "/assets/useTranslation-DcJzacty.js", "/assets/context-CssrF-fD.js", "/assets/avatar-Cm_O8PBu.js"], "css": [], "clientActionModule": void 0, "clientLoaderModule": void 0, "clientMiddlewareModule": void 0, "hydrateFallbackModule": void 0 }, "features/users/screens/dashboard": { "id": "features/users/screens/dashboard", "parentId": "core/layouts/private.layout", "path": "/dashboard", "index": void 0, "caseSensitive": void 0, "hasAction": false, "hasLoader": true, "hasClientAction": false, "hasClientLoader": false, "hasClientMiddleware": false, "hasErrorBoundary": false, "module": "/assets/dashboard-BTZDjz_I.js", "imports": ["/assets/with-props-CP8Fb9K_.js", "/assets/chunk-LSOULM7L-CE8sSiXH.js", "/assets/button-ZU_4EZ5Z.js", "/assets/auth-VcATNi_0.js", "/assets/users-CoGeGUwu.js", "/assets/createLucideIcon-ClctZlHb.js", "/assets/index-DwFH84ni.js", "/assets/firebase-3OE0PJgJ.js", "/assets/useTranslation-DcJzacty.js", "/assets/context-CssrF-fD.js"], "css": [], "clientActionModule": void 0, "clientLoaderModule": void 0, "clientMiddlewareModule": void 0, "hydrateFallbackModule": void 0 }, "features/users/screens/member-list": { "id": "features/users/screens/member-list", "parentId": "core/layouts/private.layout", "path": "/members", "index": void 0, "caseSensitive": void 0, "hasAction": false, "hasLoader": false, "hasClientAction": false, "hasClientLoader": false, "hasClientMiddleware": false, "hasErrorBoundary": false, "module": "/assets/member-list-B8PujyOO.js", "imports": ["/assets/with-props-CP8Fb9K_.js", "/assets/chunk-LSOULM7L-CE8sSiXH.js"], "css": [], "clientActionModule": void 0, "clientLoaderModule": void 0, "clientMiddlewareModule": void 0, "hydrateFallbackModule": void 0 }, "features/goals/screens/goal-list": { "id": "features/goals/screens/goal-list", "parentId": "core/layouts/private.layout", "path": "/goals", "index": void 0, "caseSensitive": void 0, "hasAction": false, "hasLoader": false, "hasClientAction": false, "hasClientLoader": false, "hasClientMiddleware": false, "hasErrorBoundary": false, "module": "/assets/goal-list-DwI0EVAu.js", "imports": ["/assets/with-props-CP8Fb9K_.js", "/assets/chunk-LSOULM7L-CE8sSiXH.js"], "css": [], "clientActionModule": void 0, "clientLoaderModule": void 0, "clientMiddlewareModule": void 0, "hydrateFallbackModule": void 0 }, "features/groups/screens/group-list": { "id": "features/groups/screens/group-list", "parentId": "core/layouts/private.layout", "path": "/groups", "index": true, "caseSensitive": void 0, "hasAction": false, "hasLoader": true, "hasClientAction": false, "hasClientLoader": false, "hasClientMiddleware": false, "hasErrorBoundary": false, "module": "/assets/group-list-C9PSS6AJ.js", "imports": ["/assets/with-props-CP8Fb9K_.js", "/assets/chunk-LSOULM7L-CE8sSiXH.js", "/assets/button-ZU_4EZ5Z.js", "/assets/users-CoGeGUwu.js", "/assets/createLucideIcon-ClctZlHb.js", "/assets/groups-BdBlsHh2.js", "/assets/firebase-3OE0PJgJ.js"], "css": [], "clientActionModule": void 0, "clientLoaderModule": void 0, "clientMiddlewareModule": void 0, "hydrateFallbackModule": void 0 }, "features/groups/screens/group-detail": { "id": "features/groups/screens/group-detail", "parentId": "core/layouts/private.layout", "path": "/groups/:groupId", "index": void 0, "caseSensitive": void 0, "hasAction": false, "hasLoader": true, "hasClientAction": false, "hasClientLoader": false, "hasClientMiddleware": false, "hasErrorBoundary": false, "module": "/assets/group-detail-Cb77caxQ.js", "imports": ["/assets/with-props-CP8Fb9K_.js", "/assets/chunk-LSOULM7L-CE8sSiXH.js", "/assets/button-ZU_4EZ5Z.js", "/assets/avatar-Cm_O8PBu.js", "/assets/groups-BdBlsHh2.js", "/assets/createLucideIcon-ClctZlHb.js", "/assets/index-mkzE_evR.js", "/assets/index-ll88vSaB.js", "/assets/index-DwFH84ni.js", "/assets/firebase-3OE0PJgJ.js"], "css": [], "clientActionModule": void 0, "clientLoaderModule": void 0, "clientMiddlewareModule": void 0, "hydrateFallbackModule": void 0 } }, "url": "/assets/manifest-982b5c44.js", "version": "982b5c44", "sri": void 0 };
const assetsBuildDirectory = "build/client";
const basename = "/";
const future = { "unstable_middleware": false, "unstable_optimizeDeps": false, "unstable_splitRouteModules": false, "unstable_subResourceIntegrity": false, "unstable_viteEnvironmentApi": false };
const ssr = true;
const isSpaMode = false;
const prerender = ["/sitemap.xml", "/robots.txt"];
const publicPath = "/";
const entry = { module: entryServer };
const routes = {
  "root": {
    id: "root",
    parentId: void 0,
    path: "",
    index: void 0,
    caseSensitive: void 0,
    module: route0
  },
  "core/screens/robots": {
    id: "core/screens/robots",
    parentId: "root",
    path: "/robots.txt",
    index: void 0,
    caseSensitive: void 0,
    module: route1
  },
  "core/screens/sitemap": {
    id: "core/screens/sitemap",
    parentId: "root",
    path: "/sitemap.xml",
    index: void 0,
    caseSensitive: void 0,
    module: route2
  },
  "features/links/screens/invite-redirect": {
    id: "features/links/screens/invite-redirect",
    parentId: "root",
    path: "/invite/:code",
    index: void 0,
    caseSensitive: void 0,
    module: route3
  },
  "debug/sentry": {
    id: "debug/sentry",
    parentId: "root",
    path: "/debug/sentry",
    index: void 0,
    caseSensitive: void 0,
    module: route4
  },
  "debug/analytics": {
    id: "debug/analytics",
    parentId: "root",
    path: "/debug/analytics",
    index: void 0,
    caseSensitive: void 0,
    module: route5
  },
  "features/settings/api/set-theme": {
    id: "features/settings/api/set-theme",
    parentId: "root",
    path: "/api/settings/theme",
    index: void 0,
    caseSensitive: void 0,
    module: route6
  },
  "features/settings/api/set-locale": {
    id: "features/settings/api/set-locale",
    parentId: "root",
    path: "/api/settings/locale",
    index: void 0,
    caseSensitive: void 0,
    module: route7
  },
  "core/layouts/navigation.layout": {
    id: "core/layouts/navigation.layout",
    parentId: "root",
    path: void 0,
    index: void 0,
    caseSensitive: void 0,
    module: route8
  },
  "features/home/screens/home": {
    id: "features/home/screens/home",
    parentId: "core/layouts/navigation.layout",
    path: void 0,
    index: true,
    caseSensitive: void 0,
    module: route9
  },
  "core/screens/error": {
    id: "core/screens/error",
    parentId: "core/layouts/navigation.layout",
    path: "/error",
    index: void 0,
    caseSensitive: void 0,
    module: route10
  },
  "core/layouts/public.layout": {
    id: "core/layouts/public.layout",
    parentId: "root",
    path: void 0,
    index: void 0,
    caseSensitive: void 0,
    module: route11
  },
  "features/auth/screens/login": {
    id: "features/auth/screens/login",
    parentId: "core/layouts/public.layout",
    path: "/login",
    index: void 0,
    caseSensitive: void 0,
    module: route12
  },
  "core/layouts/private.layout": {
    id: "core/layouts/private.layout",
    parentId: "root",
    path: void 0,
    index: void 0,
    caseSensitive: void 0,
    module: route13
  },
  "features/users/screens/dashboard": {
    id: "features/users/screens/dashboard",
    parentId: "core/layouts/private.layout",
    path: "/dashboard",
    index: void 0,
    caseSensitive: void 0,
    module: route14
  },
  "features/users/screens/member-list": {
    id: "features/users/screens/member-list",
    parentId: "core/layouts/private.layout",
    path: "/members",
    index: void 0,
    caseSensitive: void 0,
    module: route15
  },
  "features/goals/screens/goal-list": {
    id: "features/goals/screens/goal-list",
    parentId: "core/layouts/private.layout",
    path: "/goals",
    index: void 0,
    caseSensitive: void 0,
    module: route16
  },
  "features/groups/screens/group-list": {
    id: "features/groups/screens/group-list",
    parentId: "core/layouts/private.layout",
    path: "/groups",
    index: true,
    caseSensitive: void 0,
    module: route17
  },
  "features/groups/screens/group-detail": {
    id: "features/groups/screens/group-detail",
    parentId: "core/layouts/private.layout",
    path: "/groups/:groupId",
    index: void 0,
    caseSensitive: void 0,
    module: route18
  }
};
export {
  serverManifest as assets,
  assetsBuildDirectory,
  basename,
  entry,
  future,
  isSpaMode,
  prerender,
  publicPath,
  routes,
  ssr
};
