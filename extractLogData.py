import re
import numpy as np
import pickle

def extract_data(file_path, seg_save_path):
    all_data = []
    save_seg_data = []
    is_continue = True
    with open(file_path, 'r') as fp:
        print('start read txt...')
        num = 0
        while is_continue:
            num += 1
            data = dict()
            for i in range(7):
                try:
                    temp = fp.readline()
                except Exception as e:
                    print(e)
                    is_continue = False
                    break
                if temp == '':
                    print('over')
                    is_continue = False
                    break
                if i == 0 or i == 6:
                    continue
                if i == 1:
                    data['worldtime'] = int(temp[1:-2])
                if i == 2:
                    extract_data = re.findall(r'\(\d+\s[\d.]+\s[\d.]+\s[\d.]+\)', temp)
                    fusionpos = []
                    for n in range(len(extract_data)):
                        sub_data = extract_data[n].strip("()")
                        values = sub_data.split()
                        sub_data_tran = []
                        for m in range(len(values)):
                            sub_data_tran.append(np.float32(values[m]))
                        sub_data_tran = np.array(sub_data_tran)
                        fusionpos.append(sub_data_tran)
                    data['fusionpos'] = fusionpos
                if i == 3:
                    extract_data = re.findall(r'\(\d+\s[\d.]+\s[\d.]+\s[\d.]+\)', temp)
                    fusionboxes = []
                    for n in range(len(extract_data)):
                        sub_data = extract_data[n].strip("()")
                        values = sub_data.split()
                        sub_data_tran = []
                        for m in range(len(values)):
                            sub_data_tran.append(np.float32(values[m]))
                        sub_data_tran = np.array(sub_data_tran)
                        fusionboxes.append(sub_data_tran)
                    data['fusionboxes'] = fusionboxes
                if i == 4:
                    extract_data = re.findall(r'\(\d+ [\d\s.-]+\)', temp)
                    t_objnum = []
                    for n in range(len(extract_data)):
                        sub_data = extract_data[n].strip("()")
                        values = sub_data.split()
                        sub_data_tran = []
                        for m in range(len(values)):
                            sub_data_tran.append(np.float32(values[m]))
                        sub_data_tran = np.array(sub_data_tran)
                        t_objnum.append(sub_data_tran)
                    data['t_objnum'] = t_objnum
            if not is_continue:
                break

            if np.mod(num,34000) == 0:
                print(f'read {num}th line data...')
                save_pickle_file = seg_save_path + '\\' + f'data_{num}.pkl'
                with open(save_pickle_file, 'wb') as file:
                    pickle.dump(save_seg_data, file)
                print('save_pickle_file saved')
                save_seg_data = []
            save_seg_data.append(data)
            all_data.append(data)
            # break
    return all_data

def extract_track_info(data):
    frame_num = len(data)
    all_track_info = []
    for n in range(frame_num):
        info = dict()
        id_list = []
        fusionpos = []
        for m in range(len(data[n]['t_objnum'])):
            id_list.append(data[n]['t_objnum'][m][1])
            fusionpos.append(data[n]['t_objnum'][m][2:5])
        pass
        info['id'] = id_list
        info['fusionpos'] = fusionpos
        info['worldtime'] = data[n]['worldtime']
        all_track_info.append(info)
    return all_track_info


if __name__ == "__main__":
    file = r'.\test.txt'
    data = extract_data(file)
    print(data[-1])
