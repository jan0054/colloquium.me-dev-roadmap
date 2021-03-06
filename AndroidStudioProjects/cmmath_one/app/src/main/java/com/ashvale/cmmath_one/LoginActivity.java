package com.ashvale.cmmath_one;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.Toast;

import com.parse.GetCallback;
import com.parse.LogInCallback;
import com.parse.ParseException;
import com.parse.ParseInstallation;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;


public class LoginActivity extends Activity {

    public static final String TAG = LoginActivity.class.getSimpleName();
    private EditText mUsername;
    private EditText mPassword;

    protected cmmathApplication app;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        mUsername = (EditText) findViewById(R.id.username);
        mPassword = (EditText) findViewById(R.id.password);

        if (isLogin())
            skip(null);
    }

    public void toast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }

    public void skip(View view) {
            Intent intent = new Intent(this, AddeventActivity.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
    }
    public boolean isLogin() {
        ParseUser user = ParseUser.getCurrentUser();
        Log.d(TAG, "User Existing: " + (user != null));
        return (user != null);
    }

    public void checkIsPerson(ParseUser selfuser) {
        String user_email = selfuser.getEmail();
        ParseQuery<ParseObject> personquery = ParseQuery.getQuery("Person");
        personquery.whereEqualTo("email", user_email);
        personquery.getFirstInBackground(new GetCallback<ParseObject>() {
            @Override
            public void done(ParseObject parseObject, ParseException e) {
                if (parseObject != null) {
                    //found a match, user is person: skip to user preference activity
                    app = (cmmathApplication) getApplication();
                    app.isPerson = true;
                } else {
                    return;
                }
            }
        });
    }

    public void updateIsPerson(ParseUser selfuser) {
        String user_email = selfuser.getEmail();
        ParseQuery<ParseObject> personquery = ParseQuery.getQuery("Person");
        personquery.whereEqualTo("email", user_email);
        personquery.getFirstInBackground(new GetCallback<ParseObject>() {
            @Override
            public void done(ParseObject parseObject, ParseException e) {
                if (parseObject != null) {
                    //found a match, user is person: skip to user preference activity
                    app = (cmmathApplication) getApplication();
                    app.isPerson = true;
                } else {
                    //toPage(new Intent(), UserAttendeeActivity.class);
                    return;
                }
            }
        });
    }

    public void login(View view) {
        String username = mUsername.getText().toString();
        String password = mPassword.getText().toString();

        // TODO: Add more check-out for username and password!
        if (username.length() == 0 || password.length() == 0) {
            toast("Wrong username and/or password!");
            return;
        }

        ParseUser.logInInBackground(username, password,
                new LogInCallback() {
                    @Override
                    public void done(ParseUser user, ParseException e) {
                        if (user != null) {
                            Log.d(TAG, "Login: " + "passed");
                            final String uid = user.getObjectId();

                            //after successful login, associate user to installation(this phone), in order to receive push notifications
                            ParseInstallation installation = ParseInstallation.getCurrentInstallation();
                            installation.put("user",ParseUser.getCurrentUser());
                            installation.saveInBackground();

                            new Handler().postDelayed(new Runnable() {
                                public void run() {
                                    app = (cmmathApplication) getApplication();
                                    checkIsPerson(ParseUser.getCurrentUser());
                                    if (!app.isPerson) {
//                                        Intent intent = new Intent(this, UserPreferenceActivity.class);
//                                        startActivity(intent);
                                    } else skip(null);
                                }
                            }, 100);
                        } else {
                            Log.d(TAG, "Login: " + "failed");
                            final int code = e.getCode();
                            final String msg = e.getMessage();
                            new Handler().postDelayed(new Runnable() {
                                public void run() {
                                    onLoginFailed(code, msg);
                                }
                            }, 100);
                        }
                    }
                });

        Log.d(TAG, "U/P: " + mUsername.getText().toString() + ", " + mPassword.getText().toString());
    }

    public void toSignupPage(View view) {
        Intent intent = new Intent(this, SignupActivity.class);
        startActivity(intent);
    }

    private void onLoginFailed(int code, String msg) {
        toast("Error (" + code + "): " + msg + "!");
    }
}
