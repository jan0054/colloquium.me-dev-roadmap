package com.ashvale.cmmath_one;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.Toast;
import com.ashvale.cmmath_one.adapter.AddEventAdapter;
import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class AddeventActivity extends BaseActivity {

    private List<String> selectedEventIds;
    private List<String> selectedEventNames;
    private List<ParseObject> totalEvents;
    private int[] selectedIPositions;
    private SharedPreferences savedEvents;
    private AddEventAdapter adapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_addevent);
            super.onCreateDrawer();

        selectedEventIds = new ArrayList<String>();
        selectedEventNames = new ArrayList<String>();

        ParseQuery query = new ParseQuery("Event");
        query.orderByDescending("start_time");
        query.findInBackground(new FindCallback<ParseObject>() {
            @Override
            public void done(List<ParseObject> list, ParseException e) {
                setAdapter(list);
            }
        });
    }

    public void setAdapter(final List<ParseObject> results)
    {
        adapter = new AddEventAdapter(this, results);
        ListView eventlist = (ListView)findViewById(R.id.eventListView);
        eventlist.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE);
        eventlist.setAdapter(adapter);

       processExisting(results);

        totalEvents = new ArrayList<ParseObject>();
        totalEvents = results;

        eventlist.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position,
                                    long id) {
                ParseObject event = totalEvents.get(position);
                String eventid = event.getObjectId();
                String eventname = event.getString("name");

                if (selectedIPositions[position] == 0) {
                    selectedEventIds.add(eventid);
                    selectedEventNames.add(eventname);
                    selectedIPositions[position] = 1;
                } else {
                    selectedEventIds.remove(eventid);
                    selectedEventNames.remove(eventname);
                    selectedIPositions[position] = 0;
                }

                savedEvents = getSharedPreferences("EVENTS", 6); //6 = readable+writable by other apps, use 0 for private
                SharedPreferences.Editor editor = savedEvents.edit();
                Set<String> setId = new HashSet<String>();
                Set<String> setName = new HashSet<String>();
                setId.addAll(selectedEventIds);
                setName.addAll(selectedEventNames);
                editor.putStringSet("eventids", setId);
                editor.putStringSet("eventnames", setName);
                editor.commit();
                
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

        refreshDrawer();   //method in BaseActivity that refreshes and then open the drawer
    }

    public void processExisting(List<ParseObject> results)   //read local storage for selected events and select them
    {
        selectedIPositions = new int[results.size()];

        savedEvents = getSharedPreferences("EVENTS", 6);
        Set<String> eventIdSet = savedEvents.getStringSet("eventids", null);
        if (eventIdSet != null)   //there were some saved events
        {
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
                    selectedIPositions[i] = 1;        // set the selectedPosition array according to the info above
                }
                else
                {
                    selectedIPositions[i] = 0;
                }
            }
        }
        else
        {
            for (int i = 0; i< results.size(); i++)
            {
                selectedIPositions[i] = 0;            //just set everything to 0 if there wasn't anything saved in local storage
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
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    }
