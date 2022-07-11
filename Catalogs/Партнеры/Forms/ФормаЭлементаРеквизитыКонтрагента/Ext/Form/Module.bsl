﻿#Область ОбработчикиСобытийФормы

// #wortmann {
// #4.2.03
// Добавляет в обработчик события вызов создания полей контрагента, устанавливает доступность группы доступа
// Галфинд Окунев 2022/07/05
// 
// Параметры:
// Отказ				- Булево
// СтандартнаяОбработка	- Булево
&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)

	Если Не Пользователи.ЭтоПолноправныйПользователь() Тогда
		
		Элементы.ГруппаДоступа.Доступность = Ложь;
		Элементы.ГруппаДоступаЧастноеЛицо.Доступность = Ложь;
		
	КонецЕсли;	
	
	гф_СоздатьРеквизитыКонтрагента();
	
	гф_ДобавитьКомандуОткрытияФормыУстановкиГруппДоступа();
	
КонецПроцедуры// } #wortmann

// #wortmann {
// #4.2.03
// Добавляет в обработчик события вызовы создания и заполнения полей контрагента
// Галфинд Окунев 2022/07/05
// 
// Параметры:
// ТекущийОбъект - СправочникОбъект.Партнеры
&НаСервере
Процедура гф_ПриЧтенииНаСервереПеред(ТекущийОбъект)

	гф_СоздатьРеквизитыКонтрагента();
	
	гф_ЗаполнитьРеквизитыКонтрагента(ТекущийОбъект);
	
КонецПроцедуры// } #wortmann

// #wortmann {
// #4.2.03
// Добавляет на форму поля контрагента если еще не созданы
// Галфинд Окунев 2022/07/05
&НаСервере
Процедура гф_СоздатьРеквизитыКонтрагента()
	
	Если Элементы.Найти("гф_ОсновнойКонтрагент") = Неопределено Тогда
		
		ДобавляемыеРеквизиты = Новый Массив;
		
		КвалификаторыСтроки10	= Новый КвалификаторыСтроки(10);
		КвалификаторыСтроки13	= Новый КвалификаторыСтроки(13);
		КвалификаторыСтроки0	= Новый КвалификаторыСтроки(0);
		
		ОписаниеТиповСтрока10			= Новый ОписаниеТипов("Строка", , КвалификаторыСтроки10);
		ОписаниеТиповСтрока13			= Новый ОписаниеТипов("Строка", , КвалификаторыСтроки13);
		ОписаниеТиповСтрока0			= Новый ОписаниеТипов("Строка", , КвалификаторыСтроки0);
		ОписаниеТиповКонтрагенты		= Новый ОписаниеТипов("СправочникСсылка.Контрагенты");
		ОписаниеТиповБулево				= Новый ОписаниеТипов("Булево");        
		ОписаниеТиповТаблицаЗначений	= Новый ОписаниеТипов("ТаблицаЗначений");
		ОписаниеТиповАдресаДоставки		= Новый ОписаниеТипов("СправочникСсылка.гф_АдресаДоставки");		
		ОписаниеТиповОрганизации		= Новый ОписаниеТипов("СправочникСсылка.Организации");		
		ОписаниеТиповПользователи		= Новый ОписаниеТипов("СправочникСсылка.Пользователи");		
		
		// #wortmann {
		// #4.2.03
		// удалил заполнение неиспользуемого реквизита гф_Код
		// Журавлев Чугуев 2022/07/12
		//РеквизитФормы_гф_Код				= Новый РеквизитФормы("гф_Код",
		//								ОписаниеТиповСтрока10, , "Код контрагента", Истина);
		// } #wortmann
		РеквизитФормы_гф_Контрагент			= Новый РеквизитФормы("гф_Контрагент",
										ОписаниеТиповКонтрагенты, , "Контрагент", Истина);
		РеквизитФормы_гф_ОсновнойКонтрагент	= Новый РеквизитФормы("гф_ОсновнойКонтрагент",
										ОписаниеТиповКонтрагенты, ,"Основной контрагент", Истина);
		РеквизитФормы_гф_Логистика			= Новый РеквизитФормы("гф_Логистика",
										ОписаниеТиповБулево, ,"Логистика", Истина);
		РеквизитФормы_гф_РС_ГЛН_номер		= Новый РеквизитФормы("гф_RC_GLN_номер",
										ОписаниеТиповСтрока13, ,"RC_GLN_номер", Истина);
		РеквизитФормы_гф_Комментарий		= Новый РеквизитФормы("гф_Комментарий",
										ОписаниеТиповСтрока0, ,"Комментарий", Истина);
		РеквизитФормы_гф_Зарегистрирован	= Новый РеквизитФормы("гф_Зарегистрирован",
										ОписаниеТиповБулево, ,"Зарегистрирован", Истина);
		
		РеквизитФормы_гф_АдресаДоставки	= Новый РеквизитФормы("гф_АдресаДоставки",
										ОписаниеТиповТаблицаЗначений, ,"Адреса доставки", Истина);   
		РеквизитФормы_Адрес				= Новый РеквизитФормы("Адрес",
										ОписаниеТиповАдресаДоставки,"гф_АдресаДоставки", "Адрес", Истина);   

		РеквизитФормы_гф_ОтветственныйМенеджер	= Новый РеквизитФормы("гф_ОтветственныйМенеджер",
										ОписаниеТиповТаблицаЗначений, ,"Ответственный менеджер", Истина);   
		РеквизитФормы_Организация				= Новый РеквизитФормы("Организация",
										ОписаниеТиповОрганизации,"гф_ОтветственныйМенеджер", "Организация", Истина);   
		РеквизитФормы_Пользователь				= Новый РеквизитФормы("Пользователь",
										ОписаниеТиповПользователи,"гф_ОтветственныйМенеджер", "Пользователь", Истина);   
										
		// #wortmann {
		// #4.2.03
		// удалил заполнение неиспользуемого реквизита гф_Код
		// Журавлев Чугуев 2022/07/12
		//ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_Код);
		// } #wortmann
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_Контрагент);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_ОсновнойКонтрагент);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_Логистика);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_РС_ГЛН_номер);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_Комментарий);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_Зарегистрирован);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_АдресаДоставки);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_Адрес);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_ОтветственныйМенеджер);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_Организация);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_Пользователь);
		
		ИзменитьРеквизиты(ДобавляемыеРеквизиты);          
		
		ТипПолеФормы = Тип("ПолеФормы");
		ТипТаблицаФормы	= Тип("ТаблицаФормы");
		
		НовоеПоле = Элементы.Добавить("гф_ОсновнойКонтрагент", ТипПолеФормы,
										Элементы.ГруппаНаименование);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_ОсновнойКонтрагент";  
		
		НовоеПоле = Элементы.Добавить("гф_Логистика", ТипПолеФормы,
										Элементы.ГруппаОтношения);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеФлажка;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_Логистика";  
		
		НовоеПоле = Элементы.Добавить("гф_Зарегистрирован", ТипПолеФормы,
										Элементы.ГруппаОтношения);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеФлажка;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_Зарегистрирован";  
		
		НовоеПоле = Элементы.Добавить("РеквизитФормы_гф_РС_ГЛН_номер", ТипПолеФормы,
										Элементы.ГруппаИдентификация);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_RC_GLN_номер";  
		
		НовоеПоле = Элементы.Добавить("гф_Комментарий",ТипПолеФормы, ЭтотОбъект);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Ложь; // Возможно в дальнейшем потребуется, пока не удаляем
		НовоеПоле.ПутьКДанным	= "гф_Комментарий";  
		
		НовоеПоле = Элементы.Добавить("гф_АдресаДоставки", ТипТаблицаФормы,
										Элементы.ГруппаКонтактнаяИнформация);
		
		НовоеПоле.Видимость				= Истина;
		НовоеПоле.ПутьКДанным			= "гф_АдресаДоставки";
		НовоеПоле.Отображение			= ОтображениеТаблицы.Список;  
		НовоеПоле.ПоложениеЗаголовка	= ПоложениеЗаголовкаЭлементаФормы.Лево;
		
		НовоеПоле = Элементы.Добавить("гф_АдресаДоставки_Адрес", ТипПолеФормы,
										Элементы.гф_АдресаДоставки);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_АдресаДоставки.Адрес";  
		
		// #wortmann {
		// #4.2.03
		// Удалил фильтр по владельцу при выборе адреса
		// Можем выбрать любой адрес из списка, обновится владелец в справочнике адресов при записи партнера
		// Журавлев Чугуев 2022/07/12
		//НоваяСвязь = Новый СвязьПараметраВыбора("Отбор.Владелец", "гф_Контрагент");
		//НовыйМассив = Новый Массив();
		//НовыйМассив.Добавить(НоваяСвязь);
		//НовоеПоле.СвязиПараметровВыбора	= Новый ФиксированныйМассив(НовыйМассив);
		// } #wortmann
		
		НовоеПоле = Элементы.Добавить("гф_ОтветственныйМенеджер", ТипТаблицаФормы,
										Элементы.ГруппаОбщаяИнформация);
		
		НовоеПоле.Видимость				= Истина;
		НовоеПоле.ПутьКДанным			= "гф_ОтветственныйМенеджер";
		НовоеПоле.Отображение			= ОтображениеТаблицы.Список;  
		НовоеПоле.ПоложениеЗаголовка	= ПоложениеЗаголовкаЭлементаФормы.Лево;
		
		НовоеПоле = Элементы.Добавить("гф_ОтветственныйМенеджер_Организация", ТипПолеФормы,
										Элементы.гф_ОтветственныйМенеджер);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_ОтветственныйМенеджер.Организация";  
		
		НовоеПоле = Элементы.Добавить("гф_ОтветственныйМенеджер_Пользователь", ТипПолеФормы,
										Элементы.гф_ОтветственныйМенеджер);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_ОтветственныйМенеджер.Пользователь";  
		
	КонецЕсли;	      
	
КонецПроцедуры// } #wortmann

// #wortmann {
// #4.2.03
// Заполняет поля из справочника контрагенты в форме
// Галфинд Окунев 2022/07/07
// 
// Параметры:
// Партнер - СправочникОбъект.Партнеры - Параметр ТекущийОбъект обработчика ПриЧтенииНаСервере
&НаСервере
Процедура гф_ЗаполнитьРеквизитыКонтрагента(Партнер)
	
	Запрос = Новый Запрос;  
	
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
	               |	Контрагенты.Ссылка КАК Ссылка
	               |ПОМЕСТИТЬ ВТ_Контрагенты
	               |ИЗ
	               |	Справочник.Контрагенты КАК Контрагенты
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Партнеры КАК Партнеры
	               |		ПО Контрагенты.Партнер = Партнеры.Ссылка
	               |			И (Партнеры.Ссылка = &Партнер)
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	Контрагенты.Ссылка КАК гф_Контрагент,
				   // #wortmann {
				   // #4.2.03
				   // удалил заполнение неиспользуемого реквизита гф_Код
				   // Журавлев Чугуев 2022/07/12
				   //|	Контрагенты.гф_Код КАК гф_Код,
				   // } #wortmann
	               |	Контрагенты.гф_ОсновнойКонтрагент КАК гф_ОсновнойКонтрагент,
	               |	Контрагенты.гф_Логистика КАК гф_Логистика,
	               |	Контрагенты.гф_RC_GLN_номер КАК гф_RC_GLN_номер,
	               |	Контрагенты.гф_Комментарий КАК гф_Комментарий,
	               |	Контрагенты.гф_Зарегистрирован КАК гф_Зарегистрирован
	               |ИЗ
	               |	ВТ_Контрагенты КАК ВТ_Контрагенты
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Контрагенты КАК Контрагенты
	               |		ПО ВТ_Контрагенты.Ссылка = Контрагенты.Ссылка
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
				   // #wortmann {
				   // #4.2.03
				   // Адреса получим из отдельного справочника, вместо ТЧ из контрагентов
				   // Журавлев Чугуев 2022/07/12
				   //|ВЫБРАТЬ
				   //|	АдресаДоставки.Адрес КАК Адрес
				   //|ИЗ        
				   //|	Справочник.Контрагенты.гф_АдресаДоставки КАК АдресаДоставки
				   //|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Контрагенты КАК ВТ_Контрагенты
				   //|		ПО АдресаДоставки.Ссылка = ВТ_Контрагенты.Ссылка
	               |ВЫБРАТЬ
	               |	АдресаДоставки.Ссылка КАК Адрес
	               |ИЗ
				   |	Справочник.гф_АдресаДоставки КАК АдресаДоставки
				   |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Контрагенты КАК ВТ_Контрагенты
				   |		ПО АдресаДоставки.Владелец = ВТ_Контрагенты.Ссылка
				   // } #wortmann
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ОтветственныйМенеджер.Организация КАК Организация,
	               |	ОтветственныйМенеджер.Пользователь КАК Пользователь
	               |ИЗ
	               |	Справочник.Контрагенты.гф_ОтветственныйМенеджер КАК ОтветственныйМенеджер
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Контрагенты КАК ВТ_Контрагенты
	               |		ПО ОтветственныйМенеджер.Ссылка = ВТ_Контрагенты.Ссылка";
	
	Запрос.УстановитьПараметр("Партнер", Партнер.Ссылка);
	
	РезультатЗапроса = Запрос.ВыполнитьПакет();
	
	Выборка = РезультатЗапроса[1].Выбрать();

	Если Выборка.Следующий() Тогда
	
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, Выборка);
		
		ЭтотОбъект["гф_АдресаДоставки"].Загрузить(РезультатЗапроса[2].Выгрузить());
		ЭтотОбъект["гф_ОтветственныйМенеджер"].Загрузить(РезультатЗапроса[3].Выгрузить());
	
	КонецЕсли;
	
КонецПроцедуры// } #wortmann

// #wortmann {
// #4.2.03
// Добавляет кнопку открытия формы установки групп доступа
// Галфинд Окунев 2022/07/08
&НаСервере
Процедура гф_ДобавитьКомандуОткрытияФормыУстановкиГруппДоступа()
	
	Команда = Команды.Добавить("гф_ОткрытьУстановкиГруппДоступа");
	
	Команда.Заголовок = "Установка групп доступа";
	Команда.Действие  = "гф_ОткрытьУстановкиГруппДоступа";
	
	КнопкаФормы = Элементы.Добавить("КнопкаПоказатьПредупреждение",	Тип("КнопкаФормы"),	Элементы.ГруппаДоступ);
		
	КнопкаФормы.ИмяКоманды	= "гф_ОткрытьУстановкиГруппДоступа";
	КнопкаФормы.Вид			= ВидКнопкиФормы.ОбычнаяКнопка;    
	
	Элементы.Переместить(КнопкаФормы, Элементы.ГруппаДоступ, Элементы.БизнесРегион);
	
КонецПроцедуры// } #wortmann

// #wortmann {
// #4.2.03
// Открывает форму установки групп доступа
// Галфинд Окунев 2022/07/08
// Параметры:
// Команда - Имя команды
&НаКлиенте
Процедура гф_ОткрытьУстановкиГруппДоступа(Команда)  
	
	ПараметрыОткрытия = Новый Структура;
	
	ПараметрыОткрытия.Вставить("ГруппаДоступаПартнера", Объект.ГруппаДоступа);
	
	ОткрытьФорму("ОбщаяФорма.гф_УстановкаГруппДоступа", ПараметрыОткрытия);
	
КонецПроцедуры// } #wortmann

// #wortmann {
// #4.2.03
// Обновляет владельца адреса при записи партнера
// Журавлев Чугуев 2022/07/12
// 
// Параметры:
// ТекущийОбъект	- СправочникОбъект.Партнеры
// ПараметрыЗаписи	- Структура

&НаСервере
Процедура гф_ПослеЗаписиНаСервереПосле(ТекущийОбъект, ПараметрыЗаписи)
	
	ИспользуемыеАдреса = Новый Массив;
	
	ТекКонтрагент = ЭтотОбъект.гф_Контрагент;
	
	Для Каждого СтрАдрес Из ЭтотОбъект.гф_АдресаДоставки Цикл
		
		ТекАдрес = СтрАдрес.Адрес;
		
		Если НЕ ЗначениеЗаполнено(ТекАдрес) Тогда
			Продолжить
		КонецЕсли;
		
		Если ТекАдрес.Владелец = ТекКонтрагент Тогда
			Продолжить;
		КонецЕсли;
		
		ИспользуемыеАдреса.Добавить(ТекАдрес);
		
	КонецЦикла;
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("Владелец", ТекКонтрагент);
	Запрос.УстановитьПараметр("ИспользуемыеАдреса", ИспользуемыеАдреса);
	
	Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ
	               |	гф_АдресаДоставки.Ссылка КАК Ссылка
	               |ИЗ
	               |	Справочник.гф_АдресаДоставки КАК гф_АдресаДоставки
	               |ГДЕ
	               |	гф_АдресаДоставки.Владелец <> &Владелец
	               |	И гф_АдресаДоставки.Ссылка В(&ИспользуемыеАдреса)
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ РАЗРЕШЕННЫЕ
	               |	гф_АдресаДоставки.Ссылка КАК Ссылка
	               |ИЗ
	               |	Справочник.гф_АдресаДоставки КАК гф_АдресаДоставки
	               |ГДЕ
	               |	гф_АдресаДоставки.Владелец = &Владелец
	               |	И НЕ гф_АдресаДоставки.Ссылка В (&ИспользуемыеАдреса)";
	
	РезультатЗапроса = Запрос.ВыполнитьПакет();
	
	ВыборкаУстановить = РезультатЗапроса[0].Выбрать();
	Пока ВыборкаУстановить.Следующий() Цикл
		АдресОбъект = ВыборкаУстановить.Ссылка.ПолучитьОбъект();
		АдресОбъект.Владелец = ТекКонтрагент;
		АдресОбъект.Записать();
	КонецЦикла;
	
	ВыборкаСнять = РезультатЗапроса[1].Выбрать();
	Пока ВыборкаСнять.Следующий() Цикл
		АдресОбъект = ВыборкаСнять.Ссылка.ПолучитьОбъект();
		АдресОбъект.ОбменДанными.Загрузка = Истина;
		АдресОбъект.Владелец = Справочники.Контрагенты.ПустаяСсылка();
		АдресОбъект.Записать();
	КонецЦикла;
	
КонецПроцедуры// } #wortmann

#КонецОбласти
