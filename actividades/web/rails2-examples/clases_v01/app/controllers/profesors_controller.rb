class ProfesorsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @profesor_pages, @profesors = paginate :profesors, :per_page => 10
    @profesors = Profesor.find(:all, :order => 'nombre')
  end

  def show
    @profesor = Profesor.find(params[:id])
  end

  def new(departamento_id=0)
    @profesor = Profesor.new
    @all_departamentos = Departamento.find(:all, :order => "nombre")
    @selected = departamento_id
  end

  def create
    @profesor = Profesor.new(params[:profesor])
    @profesor.departamento = Departamento.find(params[:departamento]) if params[:departamento]
    if @profesor.save
      flash[:notice] = 'Profesor se creó correctamente.'
      redirect_to :action => 'list'
    else
      @all_departamentos = Departamento.find(:all, :order => "nombre")
      render :action => 'new'
    end
  end

  def edit
    @profesor = Profesor.find(params[:id])
    @all_departamentos = Departamento.find(:all, :order => "nombre")
    @selected = @profesor.departamento.id.to_i
  end

  def update
    @profesor = Profesor.find(params[:id])
    @profesor.departamento = Departamento.find(params[:departamento]) if params[:departamento]
    if @profesor.update_attributes(params[:profesor])
      flash[:notice] = 'Profesor modificado correctamente.'
      redirect_to :action => 'show', :id => @profesor
    else
      render :action => 'edit'
    end
  end

  def destroy
    Profesor.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
