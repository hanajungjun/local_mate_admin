import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
// ✅ 구글 공식 NPM 라이브러리를 직접 사용 (가장 확실한 방법)
import { JWT } from "npm:google-auth-library"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // CORS 대응
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { title, body, targetType, targetValue } = await req.json()

    // 1. Secrets에서 서비스 계정 키 가져오기
    const serviceAccount = JSON.parse(Deno.env.get("FIREBASE_SERVICE_ACCOUNT")!)
    
    // 2. Google 공식 라이브러리로 인증 객체 생성
    const client = new JWT({
      email: serviceAccount.client_email,
      key: serviceAccount.private_key,
      scopes: ['https://www.googleapis.com/auth/cloud-platform'],
    });

    // 3. 액세스 토큰 획득
    const tokenResponse = await client.authorize();
    const accessToken = tokenResponse.access_token;

    // 4. FCM 메시지 구성
    // 4. FCM 메시지 구성
    const message: any = {
      notification: { title, body },
      android: {
        priority: "high", // 안드로이드 즉시 전송 보장
        notification: {
          sound: "default",
          channel_id: "high_importance_channel", // 👈 형님 매니페스트에 적은 ID
          click_action: "FLUTTER_NOTIFICATION_CLICK"
        }
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
            contentAvailable: true // 백그라운드에서도 안정적으로 수신
          }
        }
      }
    }

    if (targetType === 'token') {
      message.token = targetValue;
    } else {
      message.topic = targetValue;
    }

    // 5. 전송
    const res = await fetch(
      `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({ message }),
      }
    )

    const result = await res.json()

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    })

  } catch (error) {
    console.error("Error details:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    })
  }
})