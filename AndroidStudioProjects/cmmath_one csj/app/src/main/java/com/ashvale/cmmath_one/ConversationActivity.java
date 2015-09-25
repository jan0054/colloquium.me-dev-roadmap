package com.ashvale.cmmath_one;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;

import com.ashvale.cmmath_one.adapter.CareerAdapter;
import com.ashvale.cmmath_one.adapter.ConversationAdapter;
import com.parse.FindCallback;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;

import java.util.List;


public class ConversationActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_conversation);
        super.onCreateDrawer();

        ParseUser selfUser = ParseUser.getCurrentUser();
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Conversation");
        query.whereEqualTo("participants", selfUser);
        query.include("participants");
        query.orderByDescending("updatedAt");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    setAdapter(objects);
                } else {
                    Log.d("cm_app", "conversation query error: "+e);
                }
            }
        });
    }

    public void setAdapter(final List<ParseObject> results)
    {
        ConversationAdapter adapter = new ConversationAdapter(this, results);
        ListView conversationListView = (ListView)findViewById(R.id.conversationListView);
        conversationListView.setAdapter(adapter);
        conversationListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                ParseObject conversation = results.get(position);
                String convid = conversation.getObjectId();
                Intent intent = new Intent(ConversationActivity.this, ChatActivity.class);
                intent.putExtra("convid", convid);
                startActivity(intent);
            }
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        //getMenuInflater().inflate(R.menu.menu_fourth, menu);
        return false;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

}