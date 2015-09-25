package com.ashvale.cmmath_one.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.ashvale.cmmath_one.R;
import com.parse.ParseObject;
import com.parse.ParseUser;

import java.util.List;

/**
 * Created by csjan on 9/18/15.
 */
public class InviteeAdapter extends BaseAdapter {
    private final Context context;
    private final List invitees;

    public InviteeAdapter(Context context, List queryresults) {
        this.context = context;
        this.invitees = queryresults;
    }

    @Override
    public int getCount()
    {
        return invitees.size();
    }

    @Override
    public long getItemId(int position)
    {
        return position;
    }

    @Override
    public Object getItem(int position)
    {
        return  invitees.get(position);
    }

    @Override
    public View getView(int position, View view, ViewGroup vg)
    {
        if (view == null)
        {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

            view = inflater.inflate(R.layout.listitem_invitee, vg, false);
        }

        ParseUser invitee = (ParseUser)invitees.get(position);
        String name = invitee.getString("first_name") + " " + invitee.getString("last_name");
        TextView nameLabel = (TextView)view.findViewById(R.id.invitee_name);
        TextView institutionLabel = (TextView)view.findViewById(R.id.invitee_institution);

        nameLabel.setText(name);
        institutionLabel.setText(invitee.getString("institution"));

        return view;
    }
}