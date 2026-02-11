
import { useEffect, useState } from "react";
import { useParams } from "react-router";
import { Copy, Smartphone, Download, AlertCircle } from "lucide-react";
import { cn } from "~/core/lib/utils"; 
// Actually, standard supaplate/shadcn usually has lib/utils. I'll check or just use inline classes if unsure.
// Let's assume standard tailwind classes for now and minimal imports to be safe.

// TODO: 아래 상수들을 실제 앱 정보로 변경해주세요.
const APP_SCHEME = "omp-camera://"; // 앱의 커스텀 URL 스킴
const ANDROID_PACKAGE_NAME = "com.ohmyplay.tnmt.camera"; // 안드로이드 패키지명
const APP_STORE_ID = "123456789"; // 애플 앱스토어 ID

const APP_STORE_URL = `https://apps.apple.com/app/id${APP_STORE_ID}`;
const PLAY_STORE_URL = `https://play.google.com/store/apps/details?id=${ANDROID_PACKAGE_NAME}`;

export default function InviteRedirect() {
  const { code } = useParams();
  const [status, setStatus] = useState<"detecting" | "redirecting" | "manual">("detecting");
  const [isMobile, setIsMobile] = useState(false);

  useEffect(() => {
    // 클라이언트 사이드에서만 실행
    if (typeof window === "undefined") return;

    const userAgent = navigator.userAgent || navigator.vendor || (window as any).opera;
    const isAndroid = /android/i.test(userAgent);
    const isIOS = /iPad|iPhone|iPod/.test(userAgent) && !(window as any).MSStream;

    setIsMobile(isAndroid || isIOS);

    const redirect = () => {
      setStatus("redirecting");
      
      const deepLink = `${APP_SCHEME}invite/${code}`; // 딥링크 형식 가정

      if (isAndroid) {
        // 안드로이드: Intent 사용
        // https://developer.chrome.com/multidevice/android/intents
        const intentUrl = `intent://invite/${code}#Intent;scheme=${APP_SCHEME.replace("://", "")};package=${ANDROID_PACKAGE_NAME};end`;
        window.location.href = intentUrl;
        
        // Fallback for simple scheme if intent implementation varies or for older devices
        // setTimeout(() => { window.location.href = deepLink; }, 500);
      } else if (isIOS) {
        // iOS: 라우터 푸시 후 앱이 없으면 스토어로 이동 (타임아웃 방식)
        window.location.href = deepLink;
        
        setTimeout(() => {
           // 앱으로 이동하지 않았다면 스토어로 이동 (사용자가 페이지에 머물러 있는 경우)
           // *주의: iOS 최신 버전에서는 딥링크 실패 시 확인창이 뜰 수 있음
           window.location.href = APP_STORE_URL;
        }, 1500);
      } else {
        // PC/기타: 그냥 스토어 안내 페이지 유지
        setStatus("manual");
      }
    };

    // 자동 리다이렉트 실행
    const timer = setTimeout(() => {
      redirect();
    }, 1000); // 1초 뒤 실행 (사용자에게 "앱을 여는 중" 보여줌)

    return () => clearTimeout(timer);
  }, [code]);

  return (
    <div className="min-h-screen bg-slate-50 flex flex-col items-center justify-center p-4">
      <div className="max-w-md w-full bg-white rounded-2xl shadow-xl overflow-hidden animate-in fade-in zoom-in duration-500">
        
        {/* Header Section */}
        <div className="bg-slate-900 p-8 text-center text-white">
          <div className="mx-auto bg-slate-800 w-16 h-16 rounded-full flex items-center justify-center mb-4 ring-4 ring-slate-700">
            <Smartphone className="w-8 h-8 text-blue-400" />
          </div>
          <h1 className="text-2xl font-bold mb-2">OMP Camera 초대</h1>
          <p className="text-slate-300">
            {code ? "초대 코드가 확인되었습니다." : "초대 코드를 확인하는 중..."}
          </p>
        </div>

        {/* Content Section */}
        <div className="p-8 space-y-6">
          
          {code && (
            <div className="bg-slate-50 p-4 rounded-lg border border-slate-200 flex items-center justify-between">
              <div className="flex flex-col">
                <span className="text-xs text-slate-500 font-medium uppercase tracking-wider">초대 코드</span>
                <span className="text-xl font-mono font-bold text-slate-900">{code}</span>
              </div>
              <button 
                onClick={() => {
                  navigator.clipboard.writeText(code);
                  alert("코드가 복사되었습니다!");
                }}
                className="p-2 hover:bg-white rounded-md transition-colors text-slate-400 hover:text-blue-600"
                title="복사하기"
              >
                <Copy size={20} />
              </button>
            </div>
          )}

          <div className="space-y-3">
            <a 
              href={isMobile ? (navigator.userAgent.match(/android/i) ? `intent://invite/${code}#Intent;scheme=${APP_SCHEME.replace("://", "")};package=${ANDROID_PACKAGE_NAME};end` : `${APP_SCHEME}invite/${code}`) : "#"}
              className="w-full flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-700 text-white py-3 px-4 rounded-xl font-semibold transition-all hover:scale-[1.02] active:scale-[0.98] shadow-md shadow-blue-200"
            >
              <Smartphone size={20} />
              앱으로 열기
            </a>
            
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <span className="w-full border-t border-slate-200" />
              </div>
              <div className="relative flex justify-center text-xs uppercase">
                <span className="bg-white px-2 text-slate-500">또는 앱이 없다면</span>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <a 
                href={PLAY_STORE_URL}
                target="_blank"
                rel="noreferrer"
                className="flex flex-col items-center justify-center gap-1 bg-slate-100 hover:bg-slate-200 text-slate-700 py-3 px-2 rounded-xl text-sm font-medium transition-colors"
              >
                <Download size={16} />
                Google Play
              </a>
              <a 
                href={APP_STORE_URL}
                target="_blank"
                rel="noreferrer"
                className="flex flex-col items-center justify-center gap-1 bg-slate-100 hover:bg-slate-200 text-slate-700 py-3 px-2 rounded-xl text-sm font-medium transition-colors"
              >
                <Download size={16} />
                App Store
              </a>
            </div>
          </div>

          <div className="text-center">
            <p className="text-xs text-slate-400">
              {status === "redirecting" ? "앱을 실행하는 중입니다..." : "버튼을 눌러 직접 이동할 수 있습니다."}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
