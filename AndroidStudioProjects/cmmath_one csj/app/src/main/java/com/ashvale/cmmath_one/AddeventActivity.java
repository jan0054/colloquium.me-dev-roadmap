package com.ashvale.cmmath_one;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;

import com.ashvale.cmmath_one.adapter.AddEventAdapter;
import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class AddeventActivity extends BaseActivity {

    private List<ParseObject> selectedEvents;
    private List<String> selectedEventIds;
    private List<String> selectedEventNames;
    private List<ParseObject> totalEvents;
    private int[] selectedPositions;
    private SharedPreferences savedEvents;
    private AddEventAdapter adapter;
    SwipeRefreshLayout swipeRefresh;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_addevent);
            super.onCreateDrawer();

        swipeRefresh = (SwipeRefreshLayout) findViewById(R.id.pulltorefresh);
        swipeRefresh.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                ParseQuery query = new ParseQuery("Event");
                query.orderByDescending("start_time");
                query.findInBackground(new FindCallback<ParseObject>() {
                    @Override
                    public void done(List<ParseObject> list, ParseException e) {
                        setAdapter(list);
                        swipeRefresh.setRefreshing(false);
                    }
                });

            }
        });

        selectedEvents = new ArrayList<ParseObject>();
        selectedEventIds = new ArrayList<String>();
        selectedEventNames = new ArrayList<String>();

        ParseQuery query = new ParseQuery("Event");
        query.orderByDescending("start_time");
        query.findInBackground(new FindCallback<ParseObject>() {
            @Override
            public void done(List<ParseObject> list, ParseException e) {
                setAdapter(list);
                swipeRefresh.setRefreshing(false);
            }
        });
    }

    public void setAdapter(final List<ParseObject> results)
    {
        if(results != null) {
            Log.d("cm_app", "Event Result have " + results.size() + " events.");
            processExisting(results);
        }

        adapter = new AddEventAdapter(this, results, selectedPositions);
        ListView eventlist = (ListView)findViewById(R.id.eventListView);
        eventlist.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE);
        eventlist.setAdapter(adapter);



        totalEvents = new ArrayList<ParseObject>();
        totalEvents = results;

        eventlist.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position,
                                    long id) {
                ParseObject event = totalEvents.get(position);
                String eventid = event.getObjectId();
                String eventname = event.getString("name");

                if (selectedPositions[position] == 0) {
                    selectedEventIds.add(eventid);
                    selectedEventNames.add(eventname);
                    selectedEvents.add(event);
                    selectedPositions[position] = 1;
                } else {
                    selectedEventIds.remove(eventid);
                    selectedEventNames.remove(eventname);
                    selectedEvents.remove(event);
                    selectedPositions[position] = 0;
                }

                adapter.notifyDataSetChanged();

                //Toast.makeText(AddeventActivity.this, "eventID: " + eventid + " count: " + selectedEventIds.size(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    public void saveEvents(List eventids, List eventnames)
    {
        savedEvents = getSharedPreferences("EVENTS", 6); //6 = readable+writable by other apps, use 0 for private
        SharedPreferences.Editor editor = savedEvents.edit();
        Set<String> setId = new HashSet<String>();
        Set<String> setName = new HashSet<String>();
        setId.addAll(eventids);
        setName.addAll(eventnames);
        editor.putStringSet("eventids", setId);
        editor.putStringSet("eventnames", setName);
        editor.commit();

        if(ParseUser.getCurrentUser()!=null) {
            ParseUser user = ParseUser.getCurrentUser();
            user.put("events", selectedEvents);
            user.saveInBackground();
        }
        refreshDrawer();   //method in BaseActivity that refreshes and then open the drawer
    }

    public void processExisting(List<ParseObject> results)   //read local storage for selected events and select them
    {
        selectedPositions = new int[results.size()];

        savedEvents = getSharedPreferences("EVENTS", 6);
        Set<String> eventIdSet = savedEvents.getStringSet("eventids", null);
        if (eventIdSet != null)   //there were some saved events
        {
            Log.d("cm_app", "savedEvents size = "+eventIdSet.size());
            for (int i = 0; i< results.size(); i++)   //iterate over total number of events
            {
                ParseObject event = results.get(i);   //get the parse object at position i
                String eventid = event.getObjectId();
                int contained = 0;
                for (String idSet : eventIdSet)       //1: the parse object at position i is contained in local storage saved list, 0: otherwise
                {
                    if (eventid.equals(idSet))
                    {
                        contained = 1;
                    }
                }
                if (contained == 1)
                {
                    selectedEventIds.add(eventid);
                    selectedEventNames.add(event.getString("name"));
                    selectedEvents.add(event);
                    selectedPositions[i] = 1;        // set the selectedPosition array according to the info above
                }
                else
                {
                    selectedPositions[i] = 0;
                }
            }
        }
        else
        {
            for (int i = 0; i< results.size(); i++)
            {
                selectedPositions[i] = 0;            //just set everything to 0 if there wasn't anything saved in local storage
            }
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_addevent, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.saveevents) {
            saveEvents(selectedEventIds, selectedEventNames);
            Intent intent = new Intent(this, HomeActivity.class);
            startActivity(intent);
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

}
