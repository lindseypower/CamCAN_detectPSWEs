#################################################################################################
#Reads in dataframes of detected PSWEs and assigns each PSWE to a spatial region based on the 
#channel at which the PSWE was detected

#Author: Lindsey Power (May 2020)
#################################################################################################

import pandas as pd #v1.3.5
import numpy as np #v1.21.6
import os

#Define participants of interest
camcanCSV = '/media/NAS/lpower/camcan/oneCSVToRuleThemAll.csv'
subjectData = pd.read_csv(camcanCSV)
subjects = subjectData['SubjectID'].tolist()

#Define 8 sensor regions (see Figure 2 of associated paper for diagram)
L_frontal = ['MEG0522','MEG0521','MEG0523','MEG0531','MEG0532','MEG0533','MEG0621','MEG0622','MEG0623',
            'MEG0611','MEG0612','MEG0613','MEG0641','MEG0642','MEG0643','MEG0821','MEG0822','MEG0823',
            'MEG0511','MEG0512','MEG0513','MEG0541','MEG0542','MEG0543','MEG0331','MEG0332','MEG0333',
            'MEG0311','MEG0312','MEG0313','MEG0321','MEG0322','MEG0323','MEG0341','MEG0342','MEG0343'
            'MEG0121','MEG0122','MEG0123']
R_frontal = ['MEG0811','MEG0812','MEG0813','MEG0911','MEG0912','MEG0913','MEG0941','MEG0942','MEG0943',
            'MEG1011','MEG1012','MEG1013','MEG1021','MEG1022','MEG1023','MEG1031','MEG1032','MEG1033',
            'MEG0921','MEG0922','MEG0923','MEG0931','MEG0932','NEG0933','MEG1241','MEG1242','MEG1243',
            'MEG1211','MEG1212','MEG1213','MEG1231','MEG1232','MEG1233','MEG1221','MEG1222','MEG1223',
            'MEG1411','MEG1412','MEG1413']
L_temporal = ['MEG0111','MEG0112','MEG0113','MEG0131','MEG0132','MEG0133','MEG0211','MEG0212','MEG0213',
            'MEG0221','MEG0222','MEG0223','MEG0141','MEG0142','MEG0143','MEG1511','MEG1512','MEG1513',
            'MEG0241,','MEG0242','MEG0243','MEG0231','MEG0232','MEG0233','MEG1541','MEG1542','MEG1543',
            'MEG1521','MEG1522','MEG1523','M1611','MEG1612','MEG1613','MEG1621','MEG1622','MEG1623',
            'MEG1531','MEG1532','MEG1533']
R_temporal = ['MEG1421','MEG1422','MEG1423','MEG1311','MEG1312','MEG1313','MEG1321','MEG1322','MEG1323',
            'MEG1441','MEG1442','MEG1443','MEG1431','MEG1432','MEG1433','MEG1341','MEG1342','MEG1343',
            'MEG1331','MEG1332','MEG1333','MEG2611','MEG2612','MEG2613','MEG2411','MEG1412','MEG2413',
            'MEG2421','MEG2422','MEG2423','MEG2641','MEG2642','MEG2643','MEG2621','MEG2622','MEG2623',
            'MEG2631','MEG2632','MEG2633']
L_parietal = ['MEG0411','MEG0412','MEG0413','MEG0421','MEG0422','MEG0423','MEG0431','MEG0432','MEG0433',
            'MEG0631','MEG0632','MEG0633','MEG0441','MEG0442','MEG0443','MEG0711','MEG0712','MEG0713',
            'MEG1811','MEG1812','MEG1813','MEG1821','MEG1822','MEG1823','MEG0741','MEG0742','MEG0743',
            'MEG1631','MEG1632','MEG1633','MEG1841','MEG1842','MEG1843','MEG1831','MEG1832','MEG1833',
            'MEG2011','MEG2012','MEG2013']
R_parietal = ['MEG1041','MEG1042','MEG1043','MEG1111','MEG1112','MEG1113','MEG1121','MEG1122','MEG1123',
            'MEG0721','MEG0722','MEG0723','MEG1141','MEG1142','MEG1143','MEG1131','MEG1132','MEG1133',
            'MEG0731','MEG0732','MEG0733','MEG2211','MEG2212','MEG2213','MEG2221','MEG2222','MEG2223',
            'MEG2241','MEG2242','MEG2243','MEG2021','MEG2022','MEG2023','MEG2231','MEG2232','MEG2233',
            'MEG2441','MEG2442','MEG2443']
L_occipital = ['MEG1641','MEG1642','MEG1643','MEG1721','MEG1722','MEG1723','MEG1711','MEG1712','MEG1713',
            'MEG1731','MEG1732','MEG1733','MEG1941','MEG1942','MEG1943','MEG1911','MEG1912','MEG1913',
            'MEG1741','MEG1742','MEG1743','MEG1931','MEG1932','MEG1933','MEG1921','MEG1922','MEG1923',
            'MEG2141','MEG2142','MEG2143','MEG2041','MEG2042','MEG2043','MEG2111','MEG2112','MEG2113']
R_occipital = ['MEG2121','MEG2122','MEG2123','MEG2031','MEG2032','MEG2033','MEG2131','MEG2132','MEG2133',
            'MEG2341','MEG2342','MEG2343','MEG2331','MEG2332','MEG2333','MEG2311','MEG2312','MEG2313',
            'MEG2321','MEG2322','MEG2323','MEG2511','MEG2512','MEG2513','MEG2541','MEG1542','MEG1543',
            'MEG2431','MEG2432','MEG2433','MEG2521','MEG2522','MEG2523','MEG2531','MEG2532','MEG2533']

#Loop through each participant and for each of their events, determine which region the channel belongs to 
for subID in subjects:
    df_name = '/media/NAS/lpower/PSWE/camcan_controls/' + subID + '/' + subID + '_events.csv'
    print(df_name)
    if os.path.exists(df_name): 
        df = pd.read_csv(df_name)
        print(df)
        
        if not df.empty:
            print('not empty')
            #Pull out each column as a list
            onsets = df['Event Onset'].tolist()
            offsets = df['Event Offset'].tolist()
            channels = df['Channel'].tolist()
            frequencies = df['Mean Frequency'].tolist()
            durations = df['Event Duration'].tolist()
    
            #Variables
            new_events = []
    
            #Function to find events that belong to a given region
            def find_region(region, description, new_events):
                for target_chan in region: 
                    count = 0
                    for chan in channels:
                        if (chan == target_chan):
                            thisDict = {"Subject": subID, "Event Onset": onsets[count], "Event Offset": offsets[count], 
                            "Event Duration": durations[count], "Channel": channels[count],"Region": description, "Mean Frequency": frequencies[count]}
                            new_events.append(thisDict)
                        count = count + 1
                return new_events

            #Detect events that exist in each anatomical region and add to a new dictionary 
            new_events = find_region(L_frontal,"Left Frontal", new_events)
            new_events = find_region(R_frontal,"Right Frontal", new_events)
            new_events = find_region(L_parietal,"Left Parietal", new_events)
            new_events = find_region(R_parietal,"Right Parietal", new_events)
            new_events = find_region(L_temporal,"Left Temporal", new_events)
            new_events = find_region(R_temporal,"Right Temporal", new_events)
            new_events = find_region(L_occipital,"Left Occipital", new_events)
            new_events = find_region(R_occipital,"Right Occipital", new_events)
            
            #Save new dataframe for each subject that includes region of event
            df = pd.DataFrame(new_events)
            csv_name = '/media/NAS/lpower/PSWE/camcan_controls/' + subID + '/' + subID + '_regional_events.csv'
            df.to_csv(csv_name)
            print(df)
